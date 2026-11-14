module apb_tdm_assertions (
    input logic PCLK,
    input logic PRESETn,
    input logic PSEL,
    input logic PENABLE,
    input logic PREADY,
    input logic PSLVERR,
    input logic [3:0] tdm_req,
    input logic [3:0] tdm_grant
);

    // 1. PREADY must only be high during the ACCESS phase
    property p_pready_in_access;
        @(posedge PCLK) disable iff (!PRESETn)
        PREADY |-> (PSEL && PENABLE);
    endproperty
    assert property (p_pready_in_access) else $error("APB: PREADY high outside ACCESS phase!");

    // 2. PSLVERR must only be high during the ACCESS phase
    property p_pslverr_in_access;
        @(posedge PCLK) disable iff (!PRESETn)
        PSLVERR |-> (PSEL && PENABLE);
    endproperty
    assert property (p_pslverr_in_access) else $error("APB: PSLVERR high outside ACCESS phase!");

    // 3. TDM Grant must be one-hot or zero
    property p_grant_onehot;
        @(posedge PCLK) disable iff (!PRESETn)
        $onehot0(tdm_grant);
    endproperty
    assert property (p_grant_onehot) else $error("TDM: Grant is not one-hot!");

    // 4. TDM Grant can only happen if there is a request
    property p_grant_implies_req;
        @(posedge PCLK) disable iff (!PRESETn)
        (|tdm_grant) |-> (|tdm_req);
    endproperty
    assert property (p_grant_implies_req) else $error("TDM: Grant asserted with no request!");

endmodule