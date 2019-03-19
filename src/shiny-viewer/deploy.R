library(rsconnect)
rsconnect::setAccountInfo(name='wanntanken',
                          token='E8CCCFC3F5E21167516AE74AB83EEEFD',
                          secret='yREq1ihbXNJ9rmsSSLbq8fWxX4ns2Zc2AK6T+EUi')
deployApp(account = "wanntanken", appName='FuelChart', appDir = ".", appId = 'chartfuels')
