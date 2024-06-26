let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))
let h3TextStyle = HSwitchUtils.getTextClass((H3, Leading_1))
let p2Regular = HSwitchUtils.getTextClass((P2, Regular))
let p3Regular = HSwitchUtils.getTextClass((P3, Regular))

module TotpScanQR = {
  @react.component
  let make = (~totpUrl, ~isQrVisible) => {
    <>
      <div className="grid grid-cols-4 gap-4 w-full">
        <div className="flex flex-col gap-10 col-span-3">
          <p> {"Use any authenticator app to complete the setup"->React.string} </p>
          <div className="flex flex-col gap-4">
            <p className=p2Regular>
              {"Follow these steps to configure two factor authentication:"->React.string}
            </p>
            <div className="flex flex-col gap-4 ml-2">
              <p className={`${p2Regular} opacity-60 flex gap-2 items-center`}>
                <div className="text-white rounded-full bg-grey-900 opacity-50 px-2 py-0.5">
                  {"1"->React.string}
                </div>
                {"Scan the QR code shown on the screen with your authenticator application"->React.string}
              </p>
              <p className={`${p2Regular} opacity-60 flex gap-2 items-center`}>
                <div className="text-white rounded-full bg-grey-900 opacity-50 px-2 py-0.5">
                  {"2"->React.string}
                </div>
                {"Enter the OTP code displayed on the authenticator app in below text field or textbox"->React.string}
              </p>
            </div>
          </div>
        </div>
        <div
          className={`flex flex-col gap-2 col-span-1 items-center justify-center  ${totpUrl->String.length > 0
              ? "blur-none"
              : "blur-sm"}`}>
          <p className=p3Regular> {"Scan the QR Code into your app"->React.string} </p>
          {if isQrVisible {
            <ReactQRCode value=totpUrl size=150 />
          } else {
            <Icon
              name="spinner"
              size=20
              className="animate-spin"
              parentClass="w-full h-full flex justify-center items-center"
            />
          }}
        </div>
      </div>
      <div className="h-px w-11/12 bg-grey-200 opacity-50" />
    </>
  }
}

module TotpInput = {
  @react.component
  let make = (~otp, ~setOtp) => {
    <div className="flex flex-col gap-4 items-center">
      <p>
        {"Enter a 6-digit authentication code generated by you authenticator app"->React.string}
      </p>
      <OtpInput value={otp} setValue={setOtp} />
    </div>
  }
}

module TotpRecoveryCodes = {
  @react.component
  let make = (~setTotpStatus) => {
    let getURL = APIUtils.useGetURL()
    let fetchDetails = APIUtils.useGetMethod()
    let (recoveryCodes, setRecoveryCodes) = React.useState(_ => [])
    let firstHalf = recoveryCodes->Array.copy
    firstHalf->Array.splice(~start=0, ~remove=recoveryCodes->Array.length / 2, ~insert=[])

    let secondHalf = recoveryCodes->Array.copy
    secondHalf->Array.splice(
      ~start=recoveryCodes->Array.length / 2,
      ~remove=recoveryCodes->Array.length,
      ~insert=[],
    )

    let generateRecoveryCodes = async () => {
      open TotpTypes
      try {
        open LogicUtils
        let url = getURL(~entityName=USERS, ~userType=#GENERATE_RECOVERY_CODES, ~methodType=Get, ())
        let response = await fetchDetails(url)
        setRecoveryCodes(_ => response->getStrArryFromJson)
        // setRecoveryCodes(_ => [
        //   "adcsfda",
        //   "fvsed",
        //   "Awrefer",
        //   "Aqreffqer",
        //   "Aqrfwer",
        //   "Erfew",
        //   "erwgwrtg",
        // ])
        // setTotpStatus(_ => TOTP_SHOW_RC)
      } catch {
      // TODO : Change to TOTP_SHOW_QR
      | _ => setTotpStatus(_ => TOTP_SHOW_RC)
      }
    }

    React.useEffect(() => {
      generateRecoveryCodes()->ignore
      None
    })
    <div className={`bg-white h-40-rem w-133 rounded-2xl flex flex-col`}>
      <div className="p-6 border-b-2 flex justify-between items-center">
        <p className={`${h2TextStyle} text-grey-900`}>
          {"Two factor recovery codes"->React.string}
        </p>
      </div>
      <div className="px-8 py-8 flex flex-col flex-1 justify-between">
        <div className="flex flex-col  gap-6">
          <p className="text-jp-gray-700">
            {"Recovery codes provide a way to access your account if you lose your device and can't receive two-factor authentication codes."->React.string}
          </p>
          <HSwitchUtils.WarningArea
            warningText="These codes are the last resort for accessing your account in case you lose your password and second factors. If you cannot find these codes, you will lose access to your account."
          />
          <div
            className="border border-gray-200 rounded-md bg-jp-gray-100 py-6 px-12 flex gap-8 flex justify-evenly">
            <div className="flex flex-col gap-2 ">
              {firstHalf
              ->Array.map(recoveryCode =>
                <div className="flex items-center  gap-2">
                  <div className="p-1 rounded-full bg-jp-gray-600" />
                  <p className="text-jp-gray-700 text-xl"> {recoveryCode->React.string} </p>
                </div>
              )
              ->React.array}
            </div>
            <div className="flex flex-col gap-2 ">
              {secondHalf
              ->Array.map(recoveryCode =>
                <div className="flex items-center  gap-2">
                  <div className="p-1 rounded-full bg-jp-gray-600" />
                  <p className="text-jp-gray-700 text-xl"> {recoveryCode->React.string} </p>
                </div>
              )
              ->React.array}
            </div>
          </div>
        </div>
        <div className="flex gap-4 justify-end">
          <Button
            leftIcon={CustomIcon(<img src={`/assets/CopyToClipboard.svg`} />)}
            text={"Copy"}
            buttonType={Secondary}
            buttonSize={Small}
          />
          <Button
            leftIcon={FontAwesome("download-api-key")}
            text={"Download"}
            buttonType={Primary}
            buttonSize={Small}
          />
        </div>
      </div>
    </div>
  }
}
