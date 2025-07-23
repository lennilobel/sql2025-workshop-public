using Azure.Messaging.EventHubs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CESFunction
{
	public class ProcessCESFunction
	{
		private static int _eventCount;
		private readonly ILogger<ProcessCESFunction> _logger;

		public ProcessCESFunction(ILogger<ProcessCESFunction> logger)
		{
			this._logger = logger;
		}

		[Function("ProcessCESFunction")]
		public void Run(
			[EventHubTrigger("%EventHubName%", Connection = "EventHubConnection")]
			EventData[] events)
		{
			foreach (var eventData in events)
			{
				_eventCount++;

				try
				{
					this.ProcessEvent(eventData);
				}
				catch (Exception ex)
				{
					this._logger.LogError(ex, "Error processing event.");
				}
			}
		}

		private void ProcessEvent(EventData eventData)
		{
			var eventBodyJson = Encoding.UTF8.GetString(eventData.EventBody.ToArray());
			var eventBody = JObject.Parse(eventBodyJson);
			var data = JObject.Parse(eventBody["data"].Value<string>());

			var operation = eventBody["operation"].Value<string>();
			var columns = data["eventsource"]["cols"].ToObject<JArray>();
			var currentValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(data["eventrow"]["current"].Value<string>());
			var previousValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(data["eventrow"]["old"].Value<string>());

			this.DisplayEventMetadata(eventData, eventBody, data);

			switch (operation)
			{
				case "INS":
					this.ProcessInsert(columns, currentValues);
					break;

				case "UPD":
					this.ProcessUpdate(columns, currentValues, previousValues);
					break;

				case "DEL":
					this.ProcessDelete(columns, previousValues);
					break;
			}
		}

		private void DisplayEventMetadata(EventData eventData, JObject eventBody, JObject data)
		{
			var primaryKeyColumns = data["eventsource"]["pkkey"].ToObject<JArray>();
			var primaryKey = string.Join(", ", primaryKeyColumns.OfType<JObject>().Select(obj => $"{obj["columnname"]} = {obj["value"]}"));

			this._logger.LogInformation(" ");
			this._logger.LogInformation(" ");
			this._logger.LogInformation($"==== Processing Event {_eventCount} ====");
			this._logger.LogInformation($"Sequence     : {eventData.SequenceNumber}");
			this._logger.LogInformation($"Offset       : {eventData.Offset}");
			this._logger.LogInformation($"Time         : {eventBody["time"]}");
			this._logger.LogInformation($"Event ID     : {eventBody["id"]}");
			this._logger.LogInformation($"Database     : {data["eventsource"]["db"]}");
			this._logger.LogInformation($"Table        : {data["eventsource"]["tbl"]}");
			this._logger.LogInformation($"Operation    : {eventBody["operation"]}");
			this._logger.LogInformation($"Primary key  : {primaryKey}");
			this._logger.LogInformation(" ");
		}

		private void ProcessInsert(JArray columns, Dictionary<string, string> values)
		{
			foreach (var column in columns)
			{
				var name = column["name"].Value<string>();
				this._logger.LogInformation($"  {name,-20} {values[name]}");
			}
		}

		private void ProcessUpdate(JArray columns, Dictionary<string, string> current, Dictionary<string, string> previous)
		{
			foreach (var column in columns)
			{
				var name = column["name"].Value<string>();
				if (previous.Count > 0)
				{
					if (!previous.ContainsKey(name) || current[name] != previous[name])
					{
						this._logger.LogInformation($"  {name,-20} {current[name]} (current)");
						this._logger.LogInformation($"  {name,-20} {previous.GetValueOrDefault(name)} (previous)");
					}
				}
				else
				{
					this._logger.LogInformation($"  {name,-20} {current[name]}");
				}
			}
		}

		private void ProcessDelete(JArray columns, Dictionary<string, string> values)
		{
			foreach (var column in columns)
			{
				var name = column["name"].Value<string>();
				this._logger.LogInformation($"  {name,-20} {values[name]}");
			}
		}

	}
}
