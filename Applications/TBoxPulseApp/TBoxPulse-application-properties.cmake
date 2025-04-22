
set(APPLICATION_NAME
  TBoxPulseApp
  )

set(VERSION_MAJOR
  ${TBoxPulse_VERSION_MAJOR}
  )
set(VERSION_MINOR
  ${TBoxPulse_VERSION_MINOR}
  )
set(VERSION_PATCH
  ${TBoxPulse_VERSION_PATCH}
  )

set(DESCRIPTION_SUMMARY
  "Vehicle Network Information Processing Environment for Research"
  )
set(DESCRIPTION_FILE
  ${TBoxPulse_SOURCE_DIR}/README.md
  )

set(LAUNCHER_SPLASHSCREEN_FILE
  "${CMAKE_CURRENT_LIST_DIR}/Resources/Images/${APPLICATION_NAME}-SplashScreen.png"
  )

set(icon_file "${CMAKE_CURRENT_LIST_DIR}/Resources/${APPLICATION_NAME}-Logo.png")
if(NOT EXISTS ${icon_file})
  message(FATAL_ERROR "Linux icon File not found ")
endif()

set(LINUX_ICON_FILE
  "${CMAKE_CURRENT_LIST_DIR}/Resources/${APPLICATION_NAME}-Logo.png"
  )

set(WIN_ICON_FILE
  "${CMAKE_CURRENT_LIST_DIR}/Resources/${APPLICATION_NAME}.ico"
  )

set(LICENSE_FILE
  "${TBoxPulse_SOURCE_DIR}/License.txt"
  )
