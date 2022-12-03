{.push header: "pico/cyw43_arch.h".}

type
  Cyw43Country* = distinct uint32

  Cyw43Auth* = enum
    Open = 0  # No authorisation required (open)
    WpaTkipPsk = 0x00200002  # WPA authorisation
    Wpa2AesPsk = 0x00400004  # WPA2 authorisation (preferred)
    Wpa2MixedPsk = 0x00400006  # WPA2/WPA mixed authorisation

let CYW43_WL_GPIO_LED_PIN* {.importc: "CYW43_WL_GPIO_LED_PIN".}: cuint

proc cyw43_arch_init*(): cint {.importc: "cyw43_arch_init".}
  ## ```
  ##   !
  ##    \brief Initialize the CYW43 architecture
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This method initializes the cyw43_driver code and initializes the lwIP stack (if it
  ##    was enabled at build time). This method must be called prior to using any other \c pico_cyw43_arch,
  ##    \cyw43_driver or lwIP functions.
  ##   
  ##    \note this method initializes wireless with a country code of \c PICO_CYW43_ARCH_DEFAULT_COUNTRY_CODE
  ##    which defaults to \c CYW43_COUNTRY_WORLDWIDE. Worldwide settings may not give the best performance; consider
  ##    setting PICO_CYW43_ARCH_DEFAULT_COUNTRY_CODE to a different value or calling \ref cyw43_arch_init_with_country
  ##    \return 0 if the initialization is successful, an error code otherwise \see pico_error_codes
  ## ```

proc cyw43_arch_init_with_country*(country: Cyw43Country): cint {.importc: "cyw43_arch_init_with_country".}
  ## ```
  ##   !
  ##    \brief Initialize the CYW43 architecture for use in a specific country
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This method initializes the cyw43_driver code and initializes the lwIP stack (if it
  ##    was enabled at build time). This method must be called prior to using any other \c pico_cyw43_arch,
  ##    \cyw43_driver or lwIP functions.
  ##   
  ##    \param country the country code to use (see \ref CYW43_COUNTRY_)
  ##    \return 0 if the initialization is successful, an error code otherwise \see pico_error_codes
  ## ```

proc cyw43_arch_enable_sta_mode*() {.importc: "cyw43_arch_enable_sta_mode".}
  ## ```
  ##   !
  ##    \brief Enables Wi-Fi STA (Station) mode.
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This enables the Wi-Fi in \emStation mode such that connections can be made to other Wi-Fi Access Points
  ## ```

proc cyw43_arch_enable_ap_mode*(ssid: cstring; password: cstring; auth: uint32) {.importc: "cyw43_arch_enable_ap_mode".}
  ## ```
  ##   !
  ##    \brief Enables Wi-Fi AP (Access point) mode.
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This enables the Wi-Fi in \em Access \em Point mode such that connections can be made to the device by  other Wi-Fi clients
  ##    \param ssid the name for the access point
  ##    \param password the password to use or NULL for no password.
  ##    \param auth the authorization type to use when the password is enabled. Values are \ref CYW43_AUTH_WPA_TKIP_PSK,
  ##                \ref CYW43_AUTH_WPA2_AES_PSK, or \ref CYW43_AUTH_WPA2_MIXED_PSK (see \ref CYW43_AUTH_)
  ## ```

proc cyw43_arch_deinit*() {.importc: "cyw43_arch_deinit".}
  ## ```
  ##   !
  ##    \brief De-initialize the CYW43 architecture
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This method de-initializes the cyw43_driver code and de-initializes the lwIP stack (if it
  ##    was enabled at build time). Note this method should always be called from the same core (or RTOS
  ##    task, depending on the environment) as \ref cyw43_arch_init.
  ## ```

proc cyw43_arch_wifi_connect_blocking*(ssid: cstring; pw: cstring; auth: uint32): cint {.importc: "cyw43_arch_wifi_connect_blocking".}
  ## ```
  ##   !
  ##    \brief Attempt to connect to a wireless access point, blocking until the network is joined or a failure is detected.
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    \param ssid the network name to connect to
  ##    \param password the network password or NULL if there is no password required
  ##    \param auth the authorization type to use when the password is enabled. Values are \ref CYW43_AUTH_WPA_TKIP_PSK,
  ##                \ref CYW43_AUTH_WPA2_AES_PSK, or \ref CYW43_AUTH_WPA2_MIXED_PSK (see \ref CYW43_AUTH_)
  ##   
  ##    \return 0 if the initialization is successful, an error code otherwise \see pico_error_codes
  ## ```

proc cyw43_arch_wifi_connect_timeout_ms*(ssid: cstring; pw: cstring; auth: uint32; timeout: uint32): cint {.importc: "cyw43_arch_wifi_connect_timeout_ms".}
  ## ```
  ##   !
  ##    \brief Attempt to connect to a wireless access point, blocking until the network is joined, a failure is detected or a timeout occurs
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    \param ssid the network name to connect to
  ##    \param password the network password or NULL if there is no password required
  ##    \param auth the authorization type to use when the password is enabled. Values are \ref CYW43_AUTH_WPA_TKIP_PSK,
  ##                \ref CYW43_AUTH_WPA2_AES_PSK, or \ref CYW43_AUTH_WPA2_MIXED_PSK (see \ref CYW43_AUTH_)
  ##   
  ##    \return 0 if the initialization is successful, an error code otherwise \see pico_error_codes
  ## ```

proc cyw43_arch_wifi_connect_async*(ssid: cstring; pw: cstring; auth: uint32): cint {.importc: "cyw43_arch_wifi_connect_async".}
  ## ```
  ##   !
  ##    \brief Start attempting to connect to a wireless access point
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This method tells the CYW43 driver to start connecting to an access point. You should subsequently check the
  ##    status by calling \ref cyw43_wifi_link_status.
  ##   
  ##    \param ssid the network name to connect to
  ##    \param password the network password or NULL if there is no password required
  ##    \param auth the authorization type to use when the password is enabled. Values are \ref CYW43_AUTH_WPA_TKIP_PSK,
  ##                \ref CYW43_AUTH_WPA2_AES_PSK, or \ref CYW43_AUTH_WPA2_MIXED_PSK (see \ref CYW43_AUTH_)
  ##   
  ##    \return 0 if the scan was started successfully, an error code otherwise \see pico_error_codes
  ## ```

proc cyw43_arch_get_country_code*(): uint32 {.importc: "cyw43_arch_get_country_code".}
  ## ```
  ##   !
  ##    \brief Return the country code used to initialize cyw43_arch
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    \return the country code (see \ref CYW43_COUNTRY_)
  ## ```

proc cyw43_arch_gpio_put*(wl_gpio: cuint; value: bool) {.importc: "cyw43_arch_gpio_put".}
  ## ```
  ##   !
  ##    \brief Set a GPIO pin on the wireless chip to a given value
  ##    \ingroup pico_cyw43_arch
  ##    \note this method does not check for errors setting the GPIO. You can use the lower level \ref cyw43_gpio_set instead if you wish
  ##    to check for errors.
  ##   
  ##    \param wl_gpio the GPIO number on the wireless chip
  ##    \param value true to set the GPIO, false to clear it.
  ## ```

proc cyw43_arch_gpio_get*(wl_gpio: cuint): bool {.importc: "cyw43_arch_gpio_get".}
  ## ```
  ##   !
  ##    \brief Read the value of a GPIO pin on the wireless chip
  ##    \ingroup pico_cyw43_arch
  ##    \note this method does not check for errors setting the GPIO. You can use the lower level \ref cyw43_gpio_get instead if you wish
  ##    to check for errors.
  ##   
  ##    \param wl_gpio the GPIO number on the wireless chip
  ##    \return true if the GPIO is high, false otherwise
  ## ```

proc cyw43_arch_poll*() {.importc: "cyw43_arch_poll".}
  ## ```
  ##   !
  ##    \brief Perform any processing required by the \c cyw43_driver or the TCP/IP stack
  ##    \ingroup pico_cyw43_arch
  ##   
  ##    This method must be called periodically from the main loop when using a
  ##    \em polling style \c pico_cyw43_arch (e.g. \c pico_cyw43_arch_lwip_poll ). It
  ##    may be called in other styles, but it is unnecessary to do so.
  ## ```

{.pop.}
