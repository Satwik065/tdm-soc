`ifndef NO_SVA
bind apb_tdm_gpio_soc apb_tdm_assertions u_assertions (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .tdm_req(tdm_req),
    .tdm_grant(tdm_grant)
);
`endif