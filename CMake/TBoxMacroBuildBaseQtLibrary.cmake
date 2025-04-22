macro(TBoxMacroBuildBaseQtLibrary)
    set(options)
    set(oneValueArgs
        NAME
        EXPORT_DIRECTIVE
    )
    set(multiValueArgs
        SRCS
        MOC_SRCS
        UI_SRCS
        INCLUDE_DIRECTORIES
        TARGET_LIBRARIES
        RESOURCES
    )

    cmake_parse_arguments(TBOXQTBASELIB
     "${options}"
     "${oneValueArgs}"
     "${multiValueArgs}"
     ${ARGN}
    )

    #--------------------------------------------------------------------------------
    #Sanity checks
    #--------------------------------------------------------------------------------
    if(TBOXQTBASELIB_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to TBoxMacroBuildBaseQtLibrary() : \"${TBOXQTBASELIB_UNPARSED_ARGUMENTS}\"")
    endif()

    set(expected_defined_vars NAME EXPORT_DIRECTIVE)
    foreach(var ${expected_defined_cars})
        if(NOT DEFINED TBOXQTBASELIB_${var})
            message(FATAL_ERROR "${var} is mandatory ")
        endif()
    endforeach()

    if(NOT DEFINED TBoxPulse_INSTALL_NO_DEVELOPMENT)
        message(SEND_ERROR "TBoxPulse_INSTALL_NO_DEVELOPMENT is mandatory")
    endif()

    # --------------------------------------------------------------------------
    # Define library name
    # --------------------------------------------------------------------------
    set(lib_name ${TBOXQTBASELIB_NAME})

    #----------------------------------------------------------------------------------------
    #Update TBoxPulse_Base_INCLUDE_DIRS
    #----------------------------------------------------------------------------------------
    set(TBoxPulse_Base_INCLUDE_DIRS
        ${TBoxPulse_Base_INCLUDE_DIRS}
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        CACHE INTERNAL " TBoxPulse Base Include " FORCE)

    #-----------------------------------------------------------------------------------------
    #Configure
    #-----------------------------------------------------------------------------------------
    set(MY_LIBRARY_EXPORT_DIRECTIVE ${TBOXQTBASELIB_EXPORT_DIRECTIVE})
    set(MY_EXPORT_HEADER_PREFIX ${TBOXQTBASELIB_NAME})
    set(MY_LIBNAME ${lib_name})

    message("Debug : CMAKE_CURRENT_BINARY_DIR = ${CMAKE_CURRENT_BINARY_DIR}")
    message("Debug : MY_EXPORT_HEADER_PREFIX = ${MY_EXPORT_HEADER_PREFIX}")
    configure_file(
        ${TBoxPulse_SOURCE_DIR}/CMake/qTBoxPulseExport.h.in
        ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
    set(dynamicHeaders
        "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h"
    )


    #------------------------------------------------------------------------------------------
    #Sources
    #------------------------------------------------------------------------------------------
    set(options_moc_ OPTIONS -DTBOXPULSE_HAVEQT6)
    QT6_WRAP_CPP(TBOXPULSEQTLIB_MOC_OUTPUT ${TBOXQTBASELIB_MOC_SRCS} ${moc_options_})
    QT6_WRAP_UI(TBOXQTBASELIB_UI_CXX ${TBOXQTBASELIB_UI_SRCS})
    if(DEFINED TBOXQTBASELIB_RESOURCES)
      QT6_ADD_RESOURCES(TBOXQTBASELIB_QRC_SRCS ${TBOXQTBASELIB_RESOURCES})
    endif()

    QT6_ADD_RESOURCES(TBOXQTBASELIB_QRC_SRCS ${TBoxPulse_SOURCE_DIR}/Resources/qTBoxPulse.qrc)

    set_source_files_properties(
    ${TBOXQTBASELIB_UI_CXX}
    ${TBOXQTBASELIB_MOC_OUTPUT}
    ${TBOXQTBASELIB_QRC_SRCS}
    WRAP_EXCLUDE
    )

    # -------------------------------------------------------------------------
    # Build the library
    # --------------------------------------------------------------------------
    add_library(${lib_name}
    ${TBOXQTBASELIB_SRCS}
    ${TBOXQTBASELIB_MOC_OUTPUT}
    ${TBOXQTBASELIB_UI_CXX}
    ${TBOXQTBASELIB_QRC_SRCS}
    ${QM_OUTPUT_FILES}
    )
    if(TBOXQTBASELIB_TARGET_LIBRARIES)
        target_link_libraries(${lib_name} PUBLIC
            ${TBOXQTBASELIB_TARGET_LIBRARIES})
    endif()

    target_include_directories(${lib_name} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${TBOXQTBASELIB_INCLUDE_DIRECTORIES})
    # --------------------------------------------------------------------------
    # Install headers
    # --------------------------------------------------------------------------
    if(NOT TBOXQTBASELIB_INSTALL_NO_DEVELOPMENT)
    # Install headers
    file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    install(FILES
        ${headers}
        ${dynamicHeaders}
        DESTINATION ${TBOXQTBASELIB_INSTALL_INCLUDE_DIR}/${PROJECT_NAME} COMPONENT Development
    )
    endif()

endmacro()



