cmake_minimum_required(VERSION 3.16.3...3.19.7 FATAL_ERROR)

if("${CMAKE_VERSION}" VERSION_EQUAL "3.21.0")
    message(FATAL_ERROR "CMake version is ${CMAKE_VERSION} and using CMake==3.21.0 is not supported.\nSee https://gitlab.kitware.com/cmake/cmake/-/issues/22476")
endif()

if("${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.25.0" AND "${CMAKE_VERSION}" VERSION_LESS_EQUAL "3.25.2")
    message(FATAL_ERROR "CMake version is ${CMAKE_VERSION} and using CMake >=3.25.0,<=3.25.2 is not supported.\nSee https://gitlab.kitware.com/cmake/cmake/-/issues/24567")
endif()

#set(CMAKE_AUTOUIC ON)
#set(CMAKE_AUTOMOC ON)
#set(CMAKE_AUTORCC ON)

#-----------------------------------------------------------------------------
# Setting C++ Standard
#-----------------------------------------------------------------------------
set(msg_ "Setting C++ standard")
message(STATUS "${msg_}")
if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
message(STATUS "${msg_} - C++${CMAKE_CXX_STANDARD}")
if(NOT CMAKE_CXX_STANDARD MATCHES "^(17|20)$")
    message(FATAL_ERROR "CMAKE_CXX_STANDARD must be set to 17 or 20")
endif()

#-----------------------------------------------------------------------------
#Version
#-----------------------------------------------------------------------------
if(NOT DEFINED TBoxPulse_VERSION_MAJOR OR "${TBoxPulse_VERSION_MAJOR}" STREQUAL "")
    set(TBoxPulse_VERSION_MAJOR "1")
endif()
if(NOT DEFINED TBoxPulse_VERSION_MINOR OR "${TBoxPulse_VERSION_MINOR}" STREQUAL "")
    set(TBoxPulse_VERSION_MINOR "0")
endif()
if(NOT DEFINED TBoxPulse_VERSION_PATCH OR "${TBoxPulse_VERSION_PATCH}" STREQUAL "")
    set(TBoxPulse_VERSION_PATCH "0")
endif()

set(FULL_VERSION "${TBoxPulse_VERSION_MAJOR}.${TBoxPulse_VERSION_MINOR}.${TBoxPulse_VERSION_PATCH}")
if(NOT FULL_VERSION MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
    message(FATAL_ERROR "Invalid version format: '${FULL_VERSION}'. Expected format: 'MAJOR.MINOR.PATCH' (e.g., '1.0.0')")
endif()

project(TBoxPulse VERSION "${FULL_VERSION}")



#------------------------------------------------------------------------------
#Prevent unnecessary re-linking  on Linux
#------------------------------------------------------------------------------
if(NOT DEFINED CMAKE_LINK_DEFENDS_NO_SHRAED AND UNIX AND NOT APPLE)
    set(CMAKE_LINK_DEFENDS_NO_SHARED ON)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")
message(STATUS "CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}")
find_file(TBOX_OPPTIONS_FILE "TBoxApplicationOptions.cmake" PATH  ${CMAKE_MODULE_PATH} NO_DEFAULT_PATH)
if(NOT TBOX_OPPTIONS_FILE)
  message(STATUS "Cannot find TBoxApplicationOpptions.cmake in :${CMAKE_MODULE_PATH}")
endif()

include(TBoxApplicationOptions)


#-------------------------------------------------------------------------------
#Superbuild
#-------------------------------------------------------------------------------
set(SUPERBUILD_TOPLEVEL_PROJECT TBoxPulse)
list(APPEND EXTERNAL_PROJECT_ADDTIONAL_DIRS ${CMAKE_CURENT_SOURCE_DIR}/SuperBuild)


include(ExternalProject)

#-----------------------------------------------------------------------------
#Superbuild Option - Enabled by default
#-----------------------------------------------------------------------------
option(TBoxPulse_SUPERBUILD "Build ${PROJECT_NAME} and the project it depends on" ON)
mark_as_advanced(TBoxPulse_SUPERBUILS)
set(TBoxPulse_BINARY_INNER_SUBDIR TBoxPulse_build)

#-----------------------------------------------------------------------------
#Ctest
#-----------------------------------------------------------------------------
include(CTestUseLaunchers OPTIONAL)
if(${CTES_USE_LAUNCHERS})
    message(STATUS "CTest launchers enabled")
endif()


set(TBoxPulse_LOGOS_RESOURCE ${TBoxPulse_SOURCE_DIR}/Resources/qTBoxPulse.qrc)


#-----------------------------------------------------------------------------
#Prerequisites
#-----------------------------------------------------------------------------
find_package(Git)
if(NOT GIT_FOUND)
    message(STATUS "error : install Git and try re-configure")
endif()
#mark_as_superbuild(GIT_EXECUTABLE)


#-----------------------------------------------------------------------------
# Qt requirements
#-----------------------------------------------------------------------------
#Detect Qt version and X11Extras or WaylandExtras
set(MINIMUM_QT_VERSION "6.0")

#-------------------------------------------------------------------------------
#Qt TBoxPulse_REQUIRED_QT_MODULES
#-------------------------------------------------------------------------------
set(TBoxPulse_REQUIRED_QT_MODULES
    Widgets
    PrintSupport
    UiTools
    Svg)

set(TBoxPulse_REQUIRED_QT_VERSION ${MINIMUM_QT_VERSION} CACHE STRING "Minimum required qt version")

find_package(Qt6 ${MINIMUM_QT_VERSION} REQUIRED COMPONENTS Core)
message(STATUS "Found Qt ${Qt6_VERSION} at ${Qt6_DIR}")

if(Qt6_VERSION VERSION_LESS MINIMUM_QT_VERSION)
    message(FATAL_ERROR "Required Qt version ${Qt6_VERSION}
                         is lower than minimum required ${MINIMUM_QT_VERSION}")
endif()

find_package(Qt6 ${TBoxPulse_REQUIRED_QT_VERSION} REQUIRED COMPONENTS ${TBoxPulse_REQUIRED_QT_MODULES})
if(TBoxPulse_REQUIRED_QT_VERSION VERSION_LESS ${MINIMUM_QT_VERSION})
  message(FATAL_ERROR "\n"
        "Qt version mismach: \n"
        "Required at laest: ${MINIMUM_QT_VERSION}\n"
        "Found version : ${QT6_VERSION_STRING} \n"
        "Please install compatible Qt version")
endif()
message(STATUS "Using Qt version ${QT6_VERSION_STRING} (requide >= ${MINIMUM_QT_VERSION})")

message(STATUS "Qt PATH: ${Qt6_DIR}")
message(STATUS "Qt_VERSION: ${Qt6_VERSION}")

if(QT6_VERSION_STRING VERSION_GREATER_EQUAL "6.0")
    #Fort Qt6, use WaylandExtras for Wayland environment
    if(WAYLAND_SUPPORT OR DEFINDE ENV{WAYLAND_DISPLAY})
        find_package(QT6 REQUIRED COMPONENTS WalandClient WaylandCompositor)
        list(APPEND TBoxPulse_REQUIRED_QT_MODULES WaylandExtras)
    elseif(UNIX AND NOT APPLE)
        #Default X11Extras  for X11 if Wayland is not use
        list(APPEND TBoxPulse_REQUIRED_QT_MODULES X11Extras)
    endif()
else()
    #For QT5  only use X11Extras as WayLandExtras is not available
    if(UNIX AND NOT APPLE)
        list(APPEND TBoxPulsr_REQUIRED_QT_MODULES X11Extras)
    endif()
endif()

include_directories(${Qt6Widgets_INCLUDE_DIRS})
message(Qt6Widgets_INCLUDE_DIR = "${Qt6Widgets_INCLUDE_DIRS}")

#------------------------------------------------------------------------------
set(TBoxPulse_BIN_DIR "bin")
set(TBoxPulse_LIB_DIR "lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TBoxPulse_BINARY_DIR}/${TBoxPulse_BIN_DIR})#存放可执行文件（.exe、Linux/macOS可执行文件）
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${TBoxPulse_BINARY_DIR}/${TBoxPulse_BIN_DIR})#存放动态库（.dll、.so、.dylib）
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${TBoxPulse_BINARY_DIR}/${TBoxPulse_LIB_DIR})#存放静态库（.lib、.a）

message(STATUS "Runtime output dir: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
message(STATUS "Library output dir: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
message(STATUS "Archive output dir: ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
message(STATUS "TBocPulse_BIN_DIR = ${TBoxPulse_BIN_DIR}")
message(STATUS "TBoxPulse_LIB_DIR = ${TBoxPulse_LIB_DIR}")

set(TBoxPulse_CMAKE_DIR ${TBoxPulse_SOURCE_DIR}/CMake)
message(STATUS "TBoxPulse_SOURCE_DIR = ${TBoxPulse_SOURCE_DIR}")

if(TBoxPulse_BUILD_MULTIMEDIA_SUPPORT)
    list(APPEND TBoxPulse_REQUIRED_QT_MODULES
        Multimedia
        MultimediaWidgets
    )
endif()

#----------------------------------------------------------------------------------
# TBoxPulse include and libraries subdirectory
#---------------------------------------------------------------------------------
set(TBoxPulse_Base_LIBRARIES CACHE INTERNAL "TBoxPulse base libraries" FORCE)
set(TBoxPulse_Base_INCLUDE_DIRS CACHE INTERNAL "TBoxPulse base includes" FORCE)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/CMake
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
)


#----------------------------------------------------------------------------------
#Install no development files by default ,but allow  the user to get
#them installed by setting TBoxPulse_INSTALL_DEVELOPMENT
#----------------------------------------------------------------------------------
option(TBoxPulse_INSTALL_DEVELOPMENT "Install TBoxPulse extension development file " OFF)
mark_as_advanced(TBoxPulse_INSTALL_DEVELOPMENT)

if(NOT TBoxPulse_INSTALL_DEVELOPMENT)
    set(TBoxPulse_INSTALL_NO_DEVELOPMENT 1)
else()
    set(TBoxPulse_INSTALL_NO_DEVELOPMENT 0)
endif()


#---------------------------------------------------------------------------------------
#Documentation
#---------------------------------------------------------------------------------------
option(TBoxPulse_BUILD_DOCUMENTATION "Build documentation (Doxygen,sphinx,...)" NO)
mark_as_advanced(TBoxPulse_BUILD_DOCUMENTATION)

if(TBoxPulse_BUILD_DOCUMENTATION)
    find_package(Doxygen QUIET)

    if(DOXYGEN_DOT_FOUND)
        mark_as_advanced(DOXYGEN_EXECUTABLE)

        set(DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
        CACHE PATH "Where documentation archives should be stored")
        mark_as_advanced(DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY)

        option(DOCUMENTATION_TARGET_IN_ALL "Include the custom target for building documentation in all" OFF)
        mark_as_advanced(DOCUMENTATION_TARGET_IN_ALL)
    endif()
endif()

#---------------------------------------------------------------------------------------
add_subdirectory(Base)
add_subdirectory(Base/QTApp)

#---------------------------------------------------------------------------------------
# Building app
#---------------------------------------------------------------------------------------
add_subdirectory(${TBoxPulse_APPLICATIONS_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/Applications)

message(STATUS "TBoxPulse_APPLICATIONS_DIR = ${TBoxPulse_APPLICATIONS_DIR}")
message(STATUS "CMAKE_CURRENT_BINARY_DIR = ${CMAKE_CURRENT_BINARY_DIR}")








