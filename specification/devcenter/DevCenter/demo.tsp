import "@typespec/http";
import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";

using Http;
using Rest;
using Versioning;
using Azure.Core;
using Azure.Core.Traits;

@useAuth(
  ApiKeyAuth<ApiKeyLocation.header, "api-key"> | OAuth2Auth<[
    {
      type: OAuth2FlowType.implicit,
      authorizationUrl: "https://login.contoso.com/common/oauth2/v2.0/authorize",
      scopes: ["https://widget.contoso.com/.default"],
    }
  ]>
)
@service(#{ title: "Contoso Widget Manager" })
@server(
  "{endpoint}/widget",
  "Contoso Widget APIs",
  {
    /** 
Supported Widget Services endpoints (protocol and hostname, for example:
https://westus.api.widget.contoso.com).
 */
    endpoint: string,
  }
)
@versioned(Contoso.WidgetManager.Versions)
namespace Contoso.WidgetManager;

/** The Contoso Widget Manager service version. */
enum Versions {
  /** Version 2022-08-31 */
  @useDependency(Azure.Core.Versions.v1_0_Preview_2)
  `2022-08-30`,
}

// Models ////////////////////

@doc("The project name path parameter.")
model ProjectNameParameter {
  @doc("The DevCenter Project upon which to execute operations.")
  @maxLength(63)
  @minLength(3)
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9-_.]{2,62}$")
  @path
  projectName: string;
}

@doc("The user id path parameter.")
model UserIdParameter {
  @doc("The AAD object id of the user. If value is 'me', the identity is taken from the authentication context.")
  @maxLength(36)
  @minLength(2)
  @pattern("^[a-zA-Z0-9]{8}-([a-zA-Z0-9]{4}-){3}[a-zA-Z0-9]{12}$|^me$")
  @path
  userId: string;
}

@doc("The Dev Box name path parameter.")
model DevBoxNameParameter {
  @doc("The name of a Dev Box.")
  @maxLength(63)
  @minLength(3)
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9-_.]{2,62}$")
  @path
  devBoxName: string;
}

alias DevBoxListResult = Azure.Core.Page<DevBox>;

@doc("Indicates the provisioning state of the Dev Box.")
union DevBoxProvisioningState {
  @doc("Dev Box was successfully provisioned.") Succeeded: "Succeeded",
  @doc("Dev Box failed to provision.") Failed: "Failed",
  @doc("Dev Box provision was canceled.") Canceled: "Canceled",
  @doc("Dev Box is being created.") Creating: "Creating",
  @doc("Dev Box is being deleted.") Deleting: "Deleting",
  @doc("Dev Box is updating.") Updating: "Updating",
  @doc("Dev Box is starting.") Starting: "Starting",
  @doc("Dev Box is stopping.") Stopping: "Stopping",
  @doc("Dev Box is provisioning.") Provisioning: "Provisioning",

  @doc("Dev Box was provisioned with warning.")
  ProvisionedWithWarning: "ProvisionedWithWarning",

  @doc("Dev Box is in grace period.") InGracePeriod: "InGracePeriod",
  @doc("Dev Box is not provisioned.") NotProvisioned: "NotProvisioned",
  string,
}

@doc("Project details.")
@resource("projects")
model Project {
  @doc("The unique URI of the project.")
  uri: url;

  @key("projectName")
  @doc("Name of the project.")
  @minLength(3)
  @maxLength(63)
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9-_.]{2,62}$")
  @visibility(Lifecycle.Read)
  name: string;

  @doc("Description of the project.")
  description?: string;

  @doc("""
    When specified, indicates the maximum number of Dev Boxes a single user can
    create across all pools in the project.
    """)
  @minValue(0)
  maxDevBoxesPerUser?: int32;

  @doc("Display name of the pool.")
  displayName?: string;
}

@doc("Project user.")
@resource("users")
@parentResource(Project)
model User {
  @key("userId")
  @doc("The AAD object id of the user. If value is 'me', the identity is taken from the authentication context.")
  @minLength(2)
  @maxLength(36)
  @pattern("^[a-zA-Z0-9]{8}-([a-zA-Z0-9]{4}-){3}[a-zA-Z0-9]{12}$|^me$")
  @visibility(Lifecycle.Read)
  userId: string;
}

@doc("The current status of an async operation.")
@resource("operationstatuses")
@parentResource(Project)
model OperationStatus {
  @doc("Fully qualified ID for the operation status.")
  @visibility(Lifecycle.Read)
  id: string;

  @doc("The operation id name.")
  @maxLength(36)
  @minLength(36)
  @pattern("^[a-zA-Z0-9]{8}-([a-zA-Z0-9]{4}-){3}[a-zA-Z0-9]{12}$")
  @key("operationId")
  @visibility(Lifecycle.Read)
  name: Azure.Core.uuid;

  @doc("Provisioning state of the resource.")
  status: Azure.Core.Foundations.OperationState;

  @doc("The id of the resource.")
  resourceId?: string;

  @doc("The start time of the operation, in RFC3339 format.")
  startTime?: utcDateTime;

  @doc("The end time of the operation, in RFC3339 format.")
  endTime?: utcDateTime;

  @doc("Percent of the operation that is complete.")
  @minValue(0.0)
  @maxValue(100.0)
  percentComplete?: float64;

  #suppress "@azure-tools/typespec-azure-core/bad-record-type" "Not all values are strings in this dictionary."
  @doc("Custom operation properties, populated only for a successful operation.")
  properties?: Record<unknown>;

  @doc("Operation Error message.")
  error?: Azure.Core.Foundations.Error;
}


@doc("A Dev Box.")
@resource("devboxes")
@parentResource(User)
model DevBox {
  @doc("The unique URI of the dev box.")
  @visibility(Lifecycle.Read)
  uri: url;

  @key("devBoxName")
  @doc("Display name for the Dev Box.")
  @minLength(3)
  @maxLength(63)
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9-_.]{2,62}$")
  @visibility(Lifecycle.Read)
  name: string;

  @doc("Name of the project this Dev Box belongs to.")
  @visibility(Lifecycle.Read)
  projectName?: string;

  @doc("The name of the Dev Box pool this machine belongs to.")
  @minLength(3)
  @maxLength(63)
  @pattern("^[a-zA-Z0-9][a-zA-Z0-9-_.]{2,62}$")
  @visibility(Lifecycle.Read, Lifecycle.Create)
  poolName: string;


  @doc("The current provisioning state of the Dev Box.")
  @visibility(Lifecycle.Read)
  provisioningState?: DevBoxProvisioningState;

  @doc("""
    The current action state of the Dev Box. This is state is based on previous
    action performed by user.
    """)
  @visibility(Lifecycle.Read)
  actionState?: string;

  @doc("The current power state of the Dev Box.")
  @visibility(Lifecycle.Read)
  powerState?: string;

  @doc("Provisioning or action error details. Populated only for error states.")
  @visibility(Lifecycle.Read)
  error?: Azure.Core.Foundations.Error;

  @doc("""
    Azure region where this Dev Box is located. This will be the same region as the
    Virtual Network it is attached to.
    """)
  @visibility(Lifecycle.Read)
  location?: Azure.Core.azureLocation;

}

interface OperationStatuses {
  @doc("Get the status of an operation.")
  get is StandardResourceOperations.ResourceRead<OperationStatus>;
}


interface DevBoxes {
@doc("Lists Dev Boxes in the project for a particular user.")
@route("/projects/{projectName}/users/{userId}/devboxes")
@get
listDevBoxesByUser is Azure.Core.Foundations.Operation<
  {
    ...ProjectNameParameter;
    ...UserIdParameter;
  },
  DevBoxListResult
>;

@doc("Gets a Dev Box.")
getDevBoxByUser is StandardResourceOperations.ResourceRead<DevBox>;

@doc("Creates or replaces a Dev Box.")
@finalOperation(DevBoxes.getDevBoxByUser)
@pollingOperation(OperationStatuses.get)
@route("/projects/{projectName}/users/{userId}/devboxes/{devBoxName}")
@put
createDevBox is Azure.Core.Foundations.Operation<
  {
    ...ProjectNameParameter;
    ...UserIdParameter;
    ...DevBoxNameParameter;

    @doc("Represents the body request of a Dev Box creation. Dev Box Pool name is required. Optionally set the owner of the Dev Box as local administrator")
    @bodyRoot
    body: DevBox;
  },
  DevBox | {
    @statusCode statusCode: 201;

    @header("Location")
    location: ResourceLocation<DevBox>;

    @pollingLocation
    @header("Operation-Location")
    operationLocation: string;

    @bodyRoot body?: DevBox;
  }
>;

@doc("Deletes a Dev Box.")
@pollingOperation(OperationStatuses.get)
@route("/projects/{projectName}/users/{userId}/devboxes/{devBoxName}")
@delete
deleteDevBox is Azure.Core.Foundations.Operation<
  {
    ...ProjectNameParameter;
    ...UserIdParameter;
    ...DevBoxNameParameter;
  },
  {
    @statusCode statusCode: 202;

    @header("Location")
    location: string;

    @pollingLocation
    @header("Operation-Location")
    operationLocation: string;

    @bodyRoot body: OperationStatus;
  } | {
    @statusCode statusCode: 204;
  }
>;
}
