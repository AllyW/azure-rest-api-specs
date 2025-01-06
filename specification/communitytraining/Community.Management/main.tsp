import "@typespec/http";
import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.ResourceManager;

@armProviderNamespace("Microsoft.Community")
@service({
  title: "Microsoft.Community",
})
@versioned(Versions)
@armCommonTypesVersion(Azure.ResourceManager.CommonTypes.Versions.v5)
namespace Microsoft.Community;

/** Api versions */
enum Versions {
  /** 2023-11-01 api version */
  @useDependency(Azure.ResourceManager.Versions.v1_0_Preview_1)
  `2023-11-01`,
}

interface Operations extends Azure.ResourceManager.Operations {}

#suppress "@azure-tools/typespec-azure-resource-manager/arm-resource-path-segment-invalid-chars" "Existing Template"
#suppress "@azure-tools/typespec-azure-resource-manager/arm-resource-key-invalid-chars" "Existing template"
@doc("A CommunityProviderHub resource")
model CommunityTraining is TrackedResource<CommunityTrainingProperties> {
  @doc("The name of the Community Training Resource")
  @pattern("^[a-zA-Z0-9-]{3,24}$")
  @key("communityTrainingName")
  @segment("communityTrainings")
  @path
  name: string;

}

@doc("The status of the current operation.")
@Azure.Core.lroStatus
union ProvisioningState {
  string,
  ResourceProvisioningState,

  @doc("Initial provisioning in progress")
  Provisioning: "Provisioning",

  @doc("Update in progress")
  Updating: "Updating",

  @doc("Deletion in progress")
  Deleting: "Deleting",

  @doc("Change accepted for processing")
  Accepted: "Accepted",
}


@doc("Details of the Community CommunityTraining.")
model CommunityTrainingProperties {
  @visibility("read", "create")
  @doc("The portal name (website name) of the Community Training instance")
  portalName: string;
  
  @doc("The status of the last operation.")
  testProp: PrivateEndpointConnectionProperties;

  @visibility("read")
  @doc("The status of the last operation.")
  provisioningState?: ProvisioningState;
}

#suppress "deprecated" "Existing API"
#suppress "@azure-tools/typespec-azure-resource-manager/arm-delete-operation-response-codes" "Existing API"
@armResourceOperations
interface CommunityTrainings {
  get is ArmResourceRead<CommunityTraining>;
  #suppress "@azure-tools/typespec-azure-core/invalid-final-state" "MUST CHANGE ON NEXT UPDATE"
  @Azure.Core.useFinalStateVia("azure-async-operation")
  create is ArmResourceCreateOrUpdateAsync<
    CommunityTraining,
    LroHeaders = Azure.Core.Foundations.RetryAfterHeader
  >;
  update is ArmCustomPatchAsync<
    CommunityTraining,
    Azure.ResourceManager.Foundations.ResourceUpdateModel<
      CommunityTraining,
      CommunityTrainingProperties
    >
  >;
  delete is ArmResourceDeleteAsync<CommunityTraining>;
  listByResourceGroup is ArmResourceListByParent<CommunityTraining>;
  listBySubscription is ArmListBySubscription<CommunityTraining>;
}
