import "./main.tsp";
import "@azure-tools/typespec-client-generator-core";

using TypeSpec.Versioning;
using TypeSpec.Rest;
using Azure.ClientGenerator.Core;
using Microsoft.LoadTestService;

@useDependency(APIVersions.v2024_05_01_preview)
namespace Customizations;

// Client customizations should be kept in this file only and not in other files
// Model related customizations here (Ref: https://azure.github.io/typespec-azure/docs/howtos/DataPlane%20Generation%20-%20DPG/04renaming):
@@clientName(MetricDimensionsRequest.metricname, "metric_name", "python");
@@clientName(MetricDimensionsRequest.timespan, "time_interval", "python");

#suppress "@azure-tools/typespec-azure-core/use-standard-operations"
#suppress "@azure-tools/typespec-azure-core/use-standard-names" "Existing name"
@client({
  name: "LoadTestAdministrationClient",
  service: Microsoft.LoadTestService,
})
interface AdministrationOperations {
  createOrUpdateTest is LoadTestAdministration.createOrUpdateTest;
  createOrUpdateAppComponents is LoadTestAdministration.createOrUpdateAppComponents;
  createOrUpdateServerMetricsConfig is LoadTestAdministration.createOrUpdateServerMetricsConfig;
  getAppComponents is LoadTestAdministration.getAppComponents;
  getServerMetricsConfig is LoadTestAdministration.getServerMetricsConfig;
  getTest is LoadTestAdministration.getTest;
  getTestFile is LoadTestAdministration.getTestFile;
  listTestFiles is LoadTestAdministration.listTestFiles;
  listTests is LoadTestAdministration.listTests;
  #suppress "@azure-tools/typespec-azure-core/byos" "It is limiting for users to have storage first before creating a load test also it will be breaking change for us."
  @clientName("BeginUploadTestFile", "python")
  uploadTestFile is LoadTestAdministration.uploadTestFile;
  deleteTestFile is LoadTestAdministration.deleteTestFile;
  deleteTest is LoadTestAdministration.deleteTest;

  createOrUpdateTestProfile is TestProfileAdministration.createOrUpdateTestProfile;
  deleteTestProfile is TestProfileAdministration.deleteTestProfile;
  getTestProfile is TestProfileAdministration.getTestProfile;
  listTestProfiles is TestProfileAdministration.listTestProfiles;
}

#suppress "@azure-tools/typespec-azure-core/use-standard-operations"
#suppress "@azure-tools/typespec-azure-core/use-standard-names" "Existing name"
@client({
  name: "LoadTestRunClient",
  service: Microsoft.LoadTestService,
})
interface TestRunOperations {
  @clientName("BeginTestRun", "python")
  createOrUpdateTestRun is LoadTestRun.createOrUpdateTestRun;
  createOrUpdateAppComponents is LoadTestRun.createOrUpdateAppComponents;
  createOrUpdateServerMetricsConfig is LoadTestRun.createOrUpdateServerMetricsConfig;
  deleteTestRun is LoadTestRun.deleteTestRun;
  getAppComponents is LoadTestRun.getAppComponents;
  getServerMetricsConfig is LoadTestRun.getServerMetricsConfig;
  getTestRun is LoadTestRun.getTestRun;
  getTestRunFile is LoadTestRun.getTestRunFile;
  listMetricDimensionValues is LoadTestRun.listMetricDimensionValues;
  @clientName("get_metric_definitions", "python")
  @clientName("getMetricDefinitions", "java")
  listMetricDefinitions is LoadTestRun.listMetricDefinitions;
  @clientName("get_metric_namespaces", "python")
  @clientName("getMetricNamespaces", "java")
  listMetricNamespaces is LoadTestRun.listMetricNamespaces;
  listMetrics is LoadTestRun.listMetrics;
  listTestRuns is LoadTestRun.listTestRuns;
  @clientName("stopTestRun", "javascript,python,java,csharp,go")
  stop is LoadTestRun.stop;

  @clientName("BeginTestProfileRun", "python")
  createOrUpdateTestProfileRun is TestProfileRunAdministration.createOrUpdateTestProfileRun;
  deleteTestProfileRun is TestProfileRunAdministration.deleteTestProfileRun;
  getTestProfileRun is TestProfileRunAdministration.getTestProfileRun;
  listTestProfileRuns is TestProfileRunAdministration.listTestProfileRuns;
  @clientName("stopTestProfileRun", "javascript,python,java,csharp,go")
  @action("stop")
  stopTestProfileRun is TestProfileRunAdministration.stop;
}
