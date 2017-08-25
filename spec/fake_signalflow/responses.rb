AUTH = {
  "GOOD_TOKEN" => '{ "orgId" : "CfhbPnRAcAM", "userId" : "C_B0do-AgEA", "type" : "authenticated" } ',
}

# These are all binary responses, which is the default when you turn
# compression on.
EXECUTE = {
  "data('cpu.utilization').publish()" => [
      # DECODED {:channel=>"channel-1", :event=>"STREAM_START", :timestampMs=>1503966934573, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWCJ4JAgV0ff+OAQx6AQiFxJZm5qcUliboFvMUiFoamBsaWZmaWxiam5MURBZUEqxND8vJKi/BxdoPrixPRUJa5aANWVth94AAAA",

      # DECODED {:channel=>"channel-1", :event=>"JOB_START", :handle=>"DIW1ClNAcAA", :timestampMs=>1503966934651, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWAJL3+n+OAQx6AQiARQWUpOKljGxTPc0DnHzzHZ0REiV5KZm1pckphb4FsMUmBoamBsaWZmaWxiZmoIUVBZANGanJ9XUpSfowtUX5yYnqrEVQsASK/c7JEAAAA=",

      # DECODED {:channel=>"channel-1", :properties=>{:computationId=>"DIW1ClNAcAA", :dsname=>"value", :host=>"ip-10-0-1-249.us-west-2.compute.internal", :kubernetes_cluster=>"my-cluster", :kubernetes_role=>"worker", :plugin=>"signalfx-metadata", :plugin_instance=>"utilization", :sf_isPreQuantized=>true, :sf_key=>["plugin_instance", "kubernetes_cluster", "kubernetes_role", "computationId", "plugin", "dsname", "sf_metric", "host", "sf_originatingMetric"], :sf_metric=>"_SF_COMP_DIW1ClNAcAA_01-PUBLISH_METRIC", :sf_organizationID=>"CfhbPnRAcAM", :sf_originatingMetric=>"cpu.utilization", :sf_resolutionMs=>10000, :sf_singletonFixedDimensions=>["sf_metric"], :sf_type=>"MetricTimeSeries"}, :tsId=>"AAAAAEgCVmg", :type=>"metadata"}  
      "AQQDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAbVPLbsIwELzzFYhzHBHUS3tLA6iRmpYCbQ9VFZmwBAvHjvwoL/HvtZ0QaINP2Z2Z9c56c+x0u71sjRkD2us+NN8o6HkWKgUvQSgC0qJHk7J8XpRaYUU4i5dONYw/g4i+hFkYOp0hLSXDBTj0B1MN5/yaS+WypERBH/VRgAZ3976WaAtSoYFfVQefMAWCYXoWbvTCxKBAphnV0oCuTLFH57BNFJxWLWy52FwYJdU5YQ6QJDd3rHaoAIWXWOG/nJQwqTDLqipaEUoOzviZJlcpkRMBbxozRQ7g5qGEhgu+gb1NfrVrejddeW0L3v+he40Jrxm1524zPgTJbOAmXSW5IIZrxCxPKrz7fWmwlliH6WycRq/JJL160bQfoMn743M8e0qT0XwaR1fmucgxq2cSD12NaLVeTNjUSJM/xFYLdt1K7d+eqgDJqbbJxO1e0DfnAktTh4LibEx2sBySApg0XFlP+srVlVG1L6uHrDqYG9UMhF1uQzm5hVeyXunQnlEefRR59Ss04mZTOqdfuO7aoz8DAAA=", 

      # DECODED {:type=>"data", :timestampMs=>1503966930000, :timestamp=>2017-08-29 00:35:30 +0000, :data=>[{:timeseries_id=>467354735, :value=>1.9999999925494194}, {:timeseries_id=>42386515, :value=>0.4004004004004}, {:timeseries_id=>2615940080, :value=>0.599400599400599}, {:timeseries_id=>283503993, :value=>4.9049049049049}, {:timeseries_id=>2617737578, :value=>34.1240875912409}, {:timeseries_id=>987514092, :value=>24.5300751879699}, {:timeseries_id=>1208112744, :value=>46.6086956521739}], :channel=>"channel-1"}
      "AQUAAGNoYW5uZWwtMQAAAAAAAAAAAAFeK2okUAAAAAcCAAAAABvbRG8//////gAAAAIAAAAAAobEUz/ZoCkAQZn7AgAAAACb7BPwP+MuSip0G5sCAAAAABDl7XlAE56fZDI55AIAAAAAnAeBakBBD+IaKRwLAgAAAAA63ETsQDiHswHswHQCAAAAAEgCVmhAR03pvTem8w==",

      # DECODED {:channel=>"channel-1", :logicalTimestampMs=>1503966930000, :message=>{:blockSerialNumbers=>[0], :contents=>{:detectedResolutionMs=>10000, :originalResolutionMs=>1000}, :messageCode=>"JOB_DETECTED_RESOLUTION", :messageLevel=>"INFO", :numInputTimeSeries=>11, :timestampMs=>1503966634000, :tsIds=>["C7twv60AgAA", "DHjM1h5AcWU", "DHojJd_AcCs", "DCyNEo0AcAI", "DHXtv6lAgRo", "C9KUx7uAgAA", "C5syxltAgAc", "DBGoYDSAYAY", "DHo8kLnAYLU", "DFg1rg7AcA0", "DDQIL6EAcTM"]}, :type=>"message"}
      "AQIDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAbVHRboIwFH33K0ifXQJx4txbBdxwCJliNrIYg6VBtLSGFjdj/PeVUlyW2Keee8695/b00jMMgHYppZgA4/l2f7BAv6EIywuUkrgoMRdpeZzzRmUNzcHYtscDUx6lkzRPc9yQF4llZUsYOixxVaQkrMstrlTnl2Ea636rQIwKTAX/a5LFDAuMBM4WmDNSi4JRbdlZKRWrirygKbmnUpqr9tB7OSxTu4FZNNm4Xuw5seduFt4yClaxH4XgvzzAJx2HH06jjqR16dNjLZowmofh1tLStLibkT14vC0OBPczHQNwRuL7ZJswhxD0DeC+7ufWbgjRx6qFbD/LNhA5XEHnHHrMhAj6LfspTjaB+YI10Bm/rX5GdTfKGfLzDxESIiWevLDEXcIEJnry0yGgMAlao2luVflITjYVdN/9wPYgiufAWPd0kECcj21+3T/3rr82vrIUOgIAAA==",
    ],
}

# Just enough here to test the most basic functionality of preflight calls
PREFLIGHT = {
  "detect(data('cpu.utilization') > 70).publish()" => [
      # DECODED {:channel=>"channel-1", :event=>"STREAM_START", :timestampMs=>1503966934573, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWCJ4JAgV0ff+OAQx6AQiFxJZm5qcUliboFvMUiFoamBsaWZmaWxiam5MURBZUEqxND8vJKi/BxdoPrixPRUJa5aANWVth94AAAA",

      # DECODED {:channel=>"channel-1", :event=>"JOB_START", :handle=>"DIW1ClNAcAA", :timestampMs=>1503966934651, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWAJL3+n+OAQx6AQiARQWUpOKljGxTPc0DnHzzHZ0REiV5KZm1pckphb4FsMUmBoamBsaWZmaWxiZmoIUVBZANGanJ9XUpSfowtUX5yYnqrEVQsASK/c7JEAAAA=",
  ],
}

# Only supports channel-1 for now
ABORT = {:event => "CHANNEL_ABORT", :channel => "channel-1"}.to_json

# Converts one of the above base64 encoded responses to a binary array that can
# be passed to ws.send.  The given channel will be substituted for the default
# ('channel-1') one in the canned message
def b64_resp_to_bin_array(b64_resp, channel)
  raw = Base64.strict_decode64(b64_resp)
  raw[4..19] = channel + "\x00" * (16-channel.length)
  raw.unpack("c*")
end
