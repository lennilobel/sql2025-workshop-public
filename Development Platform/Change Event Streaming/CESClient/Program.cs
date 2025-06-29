using Azure;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CESClient
{
	public class Program
	{
		private static int _eventCount;

		public static async Task Main(string[] args)
		{
			// Load configuration from appsettings.json
			var config = new ConfigurationBuilder()
				.SetBasePath(Directory.GetCurrentDirectory())
				.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
				.Build();

			var eventHubHostName = config["EventHub:HostName"];
			var eventHubName = config["EventHub:Name"];
			var eventHubSasToken = config["EventHub:SasToken"];

			var blobStorageConnectionString = config["BlobStorage:ConnectionString"];
			var blobStorageContainerName = config["BlobStorage:ContainerName"];

			// Say hello
			Console.WriteLine("SQL Server 2025 Change Event Streaming Client");
			Console.WriteLine();
			Console.WriteLine($"Event Hub Configuration");
			Console.WriteLine($"  Host name:          {eventHubHostName}");
			Console.WriteLine($"  Hub name:           {eventHubName}");
			Console.WriteLine($"  SAS token:          {eventHubSasToken.Substring(0, 80)}...");
			Console.WriteLine();
			Console.WriteLine($"Blob Storage Configuration");
			Console.WriteLine($"  Connection string:  {blobStorageConnectionString.Substring(0, 80)}...");
			Console.WriteLine($"  Container name:     {blobStorageContainerName}");
			Console.WriteLine();
			Console.WriteLine("Press any key to start.");
			Console.ReadKey(intercept: true);

			Console.WriteLine();
			Console.Write("Initializing... ");

			// Create a blob container client that the event processor will use for checkpointing
			var storageClient = new BlobContainerClient(blobStorageConnectionString, blobStorageContainerName);

			// Create an event processor client to process events in the event hub
			var processor = new EventProcessorClient(
				checkpointStore: storageClient,
				EventHubConsumerClient.DefaultConsumerGroupName,
				fullyQualifiedNamespace: eventHubHostName,
				eventHubName,
				credential: new AzureSasCredential(eventHubSasToken)
			);

			// Register handlers for processing events and errors
			processor.ProcessEventAsync += ProcessEventHandler;
			processor.ProcessErrorAsync += ProcessErrorHandler;

			// Start listening for events
			Console.Write("starting... ");
			_eventCount = 0;

			await processor.StartProcessingAsync();

			Console.WriteLine("started... press any key to stop.");
			Console.WriteLine();
			Console.ReadKey(intercept: true);

			// Stop listening for events
			await processor.StopProcessingAsync();

			Console.WriteLine("Stopped");
		}

		private static async Task ProcessEventHandler(ProcessEventArgs eventArgs)
		{
			try
			{
				// Get the root JSON object from the event data body
				var eventDataBytes = eventArgs.Data.Body.ToArray();
				var eventDataJson = Encoding.UTF8.GetString(eventDataBytes);
				var eventData = JObject.Parse(eventDataJson);

				// Parse event data
				var operation = eventData["operation"].Value<string>();
				var dataJson = eventData["data"].Value<string>();
				var data = JObject.Parse(dataJson);
				var primaryKeyColumns = data["eventsource"]["pkkey"].ToObject<JArray>();
				var primaryKey = string.Join(", ", primaryKeyColumns.OfType<JObject>().Select(obj => $"{obj["columnname"]} = {obj["value"]}"));
				var columns = data["eventsource"]["cols"].ToObject<JArray>();
				var currentValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(data["eventrow"]["current"].Value<string>());
				var previousValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(data["eventrow"]["old"].Value<string>());

				// Process the event

				DisplayEventMetadata(eventArgs, eventData, data);

				switch (operation)
				{
					case "INS":
						ProcessInsert(primaryKey, columns, currentValues);
						break;
					case "UPD":
						ProcessUpdate(primaryKey, columns, currentValues, previousValues);
						break;
					case "DEL":
						ProcessDelete(primaryKey, columns, previousValues);
						break;
				}

				// Save the checkpoint (offset + sequence number) in blob storage
				await eventArgs.UpdateCheckpointAsync();
			}
			catch (Exception ex)
			{
				Console.ForegroundColor = ConsoleColor.Red;
				Console.WriteLine(ex.Message);
				Console.ResetColor();
			}
		}

		private static void DisplayEventMetadata(ProcessEventArgs eventArgs, JObject root, JObject data)
		{
			Console.ForegroundColor = ConsoleColor.White;
			Console.WriteLine();
			Console.WriteLine($"╔══════════════════════╗");
			Console.WriteLine($"║ Processing event {++_eventCount,-3} ║");
			Console.WriteLine($"╚══════════════════════╝");
			Console.WriteLine();
			Console.ResetColor();
			Console.WriteLine("Event Args");
			Console.WriteLine($"  Sequence            {eventArgs.Data.SequenceNumber}");
			Console.WriteLine($"  Offset              {eventArgs.Data.OffsetString}");
			Console.WriteLine();
			Console.WriteLine("Event Data");
			Console.WriteLine($"  Operation           {root["operation"]}");
			Console.WriteLine($"  Time                {root["time"]}");
			Console.WriteLine($"  Event ID            {root["id"]}");
			Console.WriteLine($"  Logical ID          {root["logicalid"]}");
			Console.WriteLine($"  Data content type   {root["datacontenttype"]}");
			Console.WriteLine();
			Console.WriteLine("Data");
			Console.WriteLine($"  Database            {data["eventsource"]["db"]}");
			Console.WriteLine($"  Schema              {data["eventsource"]["schema"]}");
			Console.WriteLine($"  Table               {data["eventsource"]["tbl"]}");
			Console.WriteLine();
		}

		private static void ProcessInsert(string primaryKey, JArray columns, Dictionary<string, string> current)
		{
			Console.ForegroundColor = ConsoleColor.Green;
			Console.WriteLine($"Insert");
			Console.WriteLine($"  {"Primary Key",-20}{primaryKey}");

			foreach (var column in columns)
			{
				var columnName = column["name"].Value<string>();
				Console.WriteLine($"  {columnName,-20}{current[columnName]}");
			}

			Console.ResetColor();
		}

		private static void ProcessUpdate(string primaryKey, JArray columns, Dictionary<string, string> currentValues, Dictionary<string, string> previousValues)
		{
			Console.ForegroundColor = ConsoleColor.Yellow;
			Console.WriteLine($"Update");
			Console.WriteLine($"  {"Primary Key",-20}{primaryKey}");

			foreach (var column in columns)
			{
				var columnName = column["name"].Value<string>();

				if (previousValues.Count == 0)
				{
					Console.WriteLine($"  {columnName,-20}{currentValues[columnName]}");
				}
				else if (currentValues[columnName] != previousValues[columnName])
				{
					Console.WriteLine($"  {columnName,-20}{currentValues[columnName]} (current)");
					Console.ForegroundColor = ConsoleColor.DarkYellow;
					Console.WriteLine($"  {columnName,-20}{previousValues[columnName]} (previous)");
					Console.ForegroundColor = ConsoleColor.Yellow;
				}
			}

			Console.ResetColor();
		}

		private static void ProcessDelete(string primaryKey, JArray columns, Dictionary<string, string> previous)
		{
			Console.ForegroundColor = ConsoleColor.Red;
			Console.WriteLine($"Delete");
			Console.WriteLine($"  {"Primary Key",-20}{primaryKey}");

			foreach (var column in columns)
			{
				var columnName = column["name"].Value<string>();
				Console.WriteLine($"  {columnName,-20}{previous[columnName]}");
			}

			Console.ResetColor();
		}

		private static Task ProcessErrorHandler(ProcessErrorEventArgs e)
		{
			Console.ForegroundColor = ConsoleColor.Red;
			Console.WriteLine(e.Exception.Message);
			Console.ResetColor();

			return Task.CompletedTask;
		}

	}
}
