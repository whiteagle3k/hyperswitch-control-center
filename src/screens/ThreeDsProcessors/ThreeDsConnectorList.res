let detailedCardCount = 5

@react.component
let make = () => {
  open UIUtils

  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let showConnectorIcons = configuredConnectors->Array.length > detailedCardCount
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let getConnectorList = async _ => {
    open ConnectorUtils
    try {
      let response = await fetchConnectorListResponse()
      let connectorsList =
        response
        ->ConnectorListMapper.getArrayOfConnectorListPayloadType
        ->getProcessorsListFromJson(~removeFromList=ConnectorTypes.ThreeDsAuthenticator, ())
      setConfiguredConnectors(_ => connectorsList)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect0(() => {
    getConnectorList()->ignore
    None
  })
  <div>
    <PageUtils.PageHeading
      title={"3DS Authentication Manager"}
      subTitle={"Connect and manage 3DS authentication providers to enhance the conversions"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors(
            ~connectorType=ConnectorTypes.ThreeDsAuthenticator,
          )}
          showIcons={showConnectorIcons}
          connectorsAvailableForIntegration=ConnectorUtils.threedsAuthenticatorList
          showTestProcessor=false
          urlPrefix="threeds-authenticators/new"
          connectorType=ConnectorTypes.ThreeDsAuthenticator
        />
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Previously Connected"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={configuredConnectors->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={ThreeDsTableEntity.threeDsAuthenticatorEntity(
              `threeds-authenticators`,
              ~permission=userPermissionJson.connectorsManage,
            )}
            offset
            setOffset
            currrentFetchCount={configuredConnectors->Array.map(Nullable.make)->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
