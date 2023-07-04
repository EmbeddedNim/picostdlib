
# hide a warning in lwip
set_source_files_properties(
  "${PICO_LWIP_PATH}/src/apps/altcp_tls/altcp_tls_mbedtls.c"
  PROPERTIES COMPILE_OPTIONS "-Wno-unused-result"
)

# Get the Nim include path to get nimbase.h
execute_process(
  COMMAND nim dump --dump.format:json --hints:off -
  OUTPUT_VARIABLE NIM_DUMP_JSON
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(JSON NIM_LIB_DIR GET "${NIM_DUMP_JSON}" libpath)

function(picostdlib_target target name)
  set(NIMCACHE_DIR "${CMAKE_BINARY_DIR}/${name}/nimcache")
  set(NIMCACHE_JSON_FILE "${NIMCACHE_DIR}/${name}.json")

  if(NOT EXISTS ${NIMCACHE_JSON_FILE})
    file(CONFIGURE OUTPUT ${NIMCACHE_JSON_FILE} CONTENT "")
  endif()

  set_directory_properties(PROPERTIES CMAKE_CONFIGURE_DEPENDS ${NIMCACHE_JSON_FILE})

  set(NIM_SOURCES "")
  set(NIMCACHE_JSON_DATA "")

  # Read the nimcache JSON file to get the source files
  if(EXISTS ${NIMCACHE_JSON_FILE})
    file(READ "${NIMCACHE_JSON_FILE}" NIMCACHE_JSON_DATA)
  endif()

  if(NIMCACHE_JSON_DATA)
    string(JSON cfilelength LENGTH "${NIMCACHE_JSON_DATA}" compile)
    math(EXPR cfilelength "${cfilelength} - 1")
    foreach(IDX RANGE ${cfilelength})
        string(JSON CUR_FILE GET "${NIMCACHE_JSON_DATA}" compile ${IDX} 0)
        string(REPLACE "\\" "/" CUR_FILE "${CUR_FILE}")
        list(APPEND NIM_SOURCES ${CUR_FILE})
    endforeach()
    # Suppress gcc warnings for nim-generated files
    set_source_files_properties(${NIM_SOURCES} PROPERTIES COMPILE_OPTIONS "-w")
    target_sources(${target} PRIVATE ${NIM_SOURCES})
  endif()

  target_include_directories(${target} PRIVATE ${NIM_LIB_DIR})

  set(PICOSTDLIB_IMPORTS_PATH "${CMAKE_BINARY_DIR}/${name}/imports.cmake")
  if(EXISTS ${PICOSTDLIB_IMPORTS_PATH})
    include(${PICOSTDLIB_IMPORTS_PATH}) # Include our generated file
    link_imported_libs(${target}) # call our generated function to import all pico-sdk libs we're using
  else()
    # fallback to something
    target_link_libraries(${target} pico_stdlib)
  endif()
endfunction()
