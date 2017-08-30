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

    "data('cpu.utilization').publish(); data('if_octets.rx').publish()" => [
      # DECODED {:channel=>"channel-1", :event=>"STREAM_START", :timestampMs=>1503966934573, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWCJ4JAgV0ff+OAQx6AQiFxJZm5qcUliboFvMUiFoamBsaWZmaWxiam5MURBZUEqxND8vJKi/BxdoPrixPRUJa5aANWVth94AAAA",

      # DECODED {:channel=>"channel-1", :event=>"JOB_START", :handle=>"DIW1ClNAcAA", :timestampMs=>1503966934651, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWAJL3+n+OAQx6AQiARQWUpOKljGxTPc0DnHzzHZ0REiV5KZm1pckphb4FsMUmBoamBsaWZmaWxiZmoIUVBZANGanJ9XUpSfowtUX5yYnqrEVQsASK/c7JEAAAA=",

      # {:channel=>"channel-1", :properties=>{:computationId=>"DIcm066AYAA", :dsname=>"value", :host=>"ip-172-31-13-154.us-west-2.compute.internal", :kubernetes_cluster=>"kubernetes-dev", :plugin=>"signalfx-metadata", :plugin_instance=>"utilization", :sf_isPreQuantized=>true, :sf_key=>["plugin_instance", "plugin", "dsname", "sf_metric", "host", "kubernetes_cluster", "sf_originatingMetric", "computationId"], :sf_metric=>"_SF_COMP_DIcm066AYAA_01-PUBLISH_METRIC", :sf_organizationID=>"CfhbPnRAcAM", :sf_originatingMetric=>"cpu.utilization", :sf_resolutionMs=>10000, :sf_singletonFixedDimensions=>["sf_metric"], :sf_type=>"MetricTimeSeries"}, :tsId=>"AAAAAH5Npdc", :type=>"metadata"}
      "AQQDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAbVLLbsIwELzzFYhzjAgUKvWWQhGRmjYFeqiqKjLJAhaJY/lBeYh/r+2EBCg+xbszk5n1HhvNZiteY0ohbTWfqm/kthzTYjxnwCUBYbpHXTL4PGNKYkly6ieWNfLjrDMYeF+eZ3kalAiKM7DdLU4VnOvrXEhbJQy5j13Uc5HbQ27/oa0E+gUhUbdd/ADahErgFKdn7kYt9B0kiChOldBNq1SXUQLbM5ilakWoBQiy0irLHcpA4gRLfI2JCBUS07hwqyRJycGmO8PEMiIi5PChMJXkADa05Arq/gb2pvj9X9OprDjVVBzL0W44ic3FDsW5G7CA5pxoBW2KroKKdfMOP7WbUtnEiWbjaPgehNHFG0UdF4Wfz6/+bBIFL/OpP7xImvMVpuUA/JHVGC7Xi5BOvdgLroC3nuwCMdW+P0IOIk+VKQZ2m9yOPnVbaJ0UZE7HZAfJiGRAhcaKcqwXqS6Cyj0rXq1wMNesGXCzrhpysissRbmknjmT/htL4mK5K3K1Fo3TH68i/IkRAwAA",

      # DECODED {:channel=>"channel-1", :properties=>{:computationId=>"DIcm066AYAA", :dsname=>"value", :host=>"charlie-mbp", :plugin=>"signalfx-metadata", :plugin_instance=>"utilization", :sf_isPreQuantized=>true, :sf_key=>["plugin_instance", "plugin", "dsname", "sf_metric", "host", "sf_originatingMetric", "computationId"], :sf_metric=>"_SF_COMP_DIcm066AYAA_01-PUBLISH_METRIC", :sf_organizationID=>"CfhbPnRAcAM", :sf_originatingMetric=>"cpu.utilization", :sf_resolutionMs=>10000, :sf_singletonFixedDimensions=>["sf_metric"], :sf_type=>"MetricTimeSeries"}, :tsId=>"AAAAABDl7Xk", :type=>"metadata"}
      "AQQDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAbVLLbsIwELz3KxDnpIILlXoLpKiRGjUFKrWqKsskS7BwbMuPiof499rOg0Drk70zuzuz3tPdYDDMt5gxoMPBY3cPx8PAQUJyAVITUA492ZDj80oYjTXhLCl8Vpzk1WgyiT6jyOdZUqEYrsCjP5gaaONbrnTbSVICYbUWLSaoKQnzqCIlw3SzDyvQuMAaX3MQYUpjltcNjCaUHL2glqY2iKhMwpvBTJMjeJ1aGrjgOzi44NffmkEnJeiMBD7HqpEkdw/vow5ySSzXtmdl2uE3Q/q+9G1qOOFoOUez1zRDvQGi0TjM3qcvyfIZpU+rRTLreeKyxKyxmsS+xmyzXWdsEeVRekW81eRnLsz9/8OSoDg1Lpj6rx6P7LnAytahoDmbkz0UMamAKctVzQB7rnpG9UHU/1MrWNmsJUi3S5Zy9vulVbNBkTvTmD587OrN65K7Bbg7/wIAo/wSrgIAAA==",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064020000, :logicalTimestamp=>2017-08-30 03:33:40 +0000, :data=>{467354735=>1.7034068128044026, 42386515=>0.599400599400599, 41123 35213=>60.8719646799117, 2615940080=>0.5, 4118409090=>1.50602409638554, 2617737578=>32.3408153916628, 987514092=>24.6498599439776}, :channel=>"channel-1"}
      "AQUBAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAY2BgjDM0nqfAwMDAzgQkGKRvu+Tb/3ZUb+gpOQAWYGo7Emz/WM9Lq0R6Nljgq6xjroNf/pzOx/uKwAKz3wh/sH/AAAYQFZXvm+x/SKzZyZ/9Ciwwh70xy8FBe/61HVNVwAJWd1zeOFgsiwUiawAddLYrgwAAAA==",

      # DECODED {:channel=>"channel-1", :properties=>{:computationId=>"DIcm066AYAA", :host=>"charlie-mbp", :plugin=>"interface", :plugin_instance=>"vboxnet5", :sf_isPreQuantized=>true, :sf_key=>["plugin_instance", "plugin", "sf_metric", "host", "sf_originatingMetric", "computationId"], :sf_metric=>"_SF_COMP_DIcm066AYAA_03-PUBLISH_METRIC", :sf_organizationID=>"CfhbPnRAcAM", :sf_originatingMetric=>"if_octets.rx", :sf_resolutionMs=>10000, :sf_singletonFixedDimensions=>["sf_metric"], :sf_type=>"MetricTimeSeries"}, :tsId=>"AAAAAEN01Ss", :type =>"metadata"}
      "AQQDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAZVJNb8IwDL3zK1DPMBVN47Bbx4dWad06yg7TNEWhNRCtdarEnfgQ/31JSkthOSV+z89+jo+9ft9LtxwRcq//2N6HI29goVLJEhQJ0BY9mpDly6KsiJOQGGYuaxqmhT8eB59B4PIMaSs1NYoqFzAsVmWDlXm1EehQgQRqzVO4xphATRxN2JJ+V3KHQA8NR6+Z0LGC94ojiQO4JkhVcMF/YG+DX/8FB239gWMWQEqk9uFaroNSCcMwFnETtfiN7+9LtbOG7ZUlczZ5i2LWmQnz74fxx9NLmDyzaLZchJOOE6k2HMWhlp06jcl6u4pxEaRBdEW87ckN0AApAek7teuQFWiZV1Yzcl838s25wNqI5EAS52IH2VQUgNpw9XlmHUsdl7Qv6/+oyy9NVgLK7oahnNy+kD5vRGDP7NUfJbrepDbZCPOME/d6pz9lbgaIfgIAAA==",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064020000, :logicalTimestamp=>2017-08-30 03:33:40 +0000, :data=>{3079061720=>696.4, 2479549961=>13556.9, 2038453579=>43.2, 3928812177=>5221.2, 2885058095=>684.1, 3689271047=>707.8, 202128297=>6316.9, 1462695611=>2833.8, 3391947226=>44.8, 1321572762=>1273.7, 1136315563=>9201.9, 122567741=>15836.6, 800290351=>776.1, 1533912710=>2461.1}, :channel=>"channel-1"}
      "AQUBAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAY2BgjDM0nqfAwMDAxwQkGLa3Hbjh0HrYGATAApNPveN0OFVVDBeobAj1dnCdCQKzwAKvdF5NdNiSitCy+ludvkNrwhkgOAsWuP30PLtDm1waCIAFeHisVzrsWPMMLhCu9223wzJlhKGndBlvObilIbT4HZ05y2HyM4ShzrvOrHY4+OMz3Fp2Pxtbh3PvfOAq9DeX6Tt0OCC0ROcua3NYbAV2KQCVBuXn+gAAAA==",

      # DECODED {:channel=>"channel-1", :logicalTimestampMs=>1504064020000, :message=>{:blockSerialNumbers=>[2], :messageCode=>"FETCH_NUM_TIMESERIES", :messageLevel=>"INFO", :numInputTimeSeries=>37, :timestampMs=>1504064020000}, :type=>"message"}
      "AQIDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFI5+emZyYk5IZm5qcUlibkFvsUgVYamBiYGZiYGRgZAAFYHlC5OTE8FSVYD+UCRpJz85Ozg1KLMxBy/0tyk1CKwzmgFI4VYHYgKqB7n/BSwPiU31xBnj3i/UN/4EE9f12DXIE/XYCVUtT6pZVB3evq5+cMk80pzPfMKSktArgTZmAq2ytgcKl2Cx/FAFbVgD5RUFkBcAfMJVy0AIrGcRhwBAAA=",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064030000, :logicalTimestamp=>2017-08-30 03:33:50 +0000, :data=>{467354735=>2.0020019944991674, 42386515=>0.5, 2615940080=>0.5, 4118409090=>1.60481444332999, 2617737578=>33.0593607305936, 987514092=>24.4611059044049, 1208112744=>48.228176318064}, :channel=>"channel-1"}
      "AQUBAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAY2BgjDM0PmrAwMDAzgQkGKRvu+Q7MLBIzlc3WQAWYGo7Emz/gAEMwAKz3wh/QBH4Wvm+yf7n2sAXT5hFwQJz2BuzHBzaZyo+86gEC1jdcXnjYFHGzRmdGQ0W8GAKy3DwkDV5uP65HQCw4NfugwAAAA==",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064030000, :logicalTimestamp=>2017-08-30 03:33:50 +0000, :data=>{3079061720=>697.4, 3553579776=>6520.5, 2885058095=>697.3, 3689271047=>676.6, 683255203=>776.4, 202128297=>5395.0, 1462695611=>2765.7, 3391947226=>44.8, 1321572762=>1238.1, 1136315563=>8868.5, 122567741=>16008.0, 800290351=>760.9, 1533912710=>2426.1}, :channel=>"channel-1"}
      "AQUBAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAY2BgjDM0PmrAwMDAywQkGLa3Hbjh0HraGATAApfPBzM47KxoALHBAqu/1ek7tJ5KAwGwwO2n59kdWlXOAMFZsIDGzqWLHTqcEWbw8FivdNgqzAA3I1zv226HpbMRZpzSZbzl4JaGEPA7OnOWw+QIhIDzrjOrHQ4GOcDNYPezsXU474IwVH9zmb5D+3GEtdG5y9ocFn0BCwAAN1jV6+kAAAA=",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064040000, :logicalTimestamp=>2017-08-30 03:34:00 +0000, :data=>{467354735=>1.6048144450164727, 42386515=>0.4004004004004, 2119017943=>1.57348510210914, 2615940080=>0.500500500500501, 4118409090=>1.60320641282565, 2617737578=>33.9399454049136, 987514092=>26.7906976744186, 1208112744=>46.9103568320279}, :channel=>"channel-1"}
      "AQUAAGNoYW5uZWwtMQAAAAAAAAAAAAFeMTPsQAAAAAgCAAAAABvbRG8/+a1R6VfoAAIAAAAAAobEUz/ZoCkAQZn7AgAAAAB+TaXXP/ks/rbk1OYCAAAAAJvsE/A/4AQZoCkARgIAAAAA9Xnvgj/5prvEfS2jAgAAAACcB4FqQED4UCGLEJACAAAAADrcROxAOsprKaymsQIAAAAASAJWaEBHdIaSmqAA",

      # DECODED {:type=>"data", :logicalTimestampMs=>1504064040000, :logicalTimestamp=>2017-08-30 03:34:00 +0000, :data=>{3079061720=>691.1, 3553579776=>5828.0, 2479549961=>9939.4, 2038453579=>94.8, 3928812177=>2952.2, 2885058095=>686.0, 3689271047=>695.4, 683255203=>756.3, 202128297=>5800.4, 1462695611=>2796.9, 3391947226=>44.8, 1321572762=>1302.3, 1136315563=>8700.8, 122567741=>16128.1, 800290351=>762.5, 1533912710=>2439.7}, :channel=>"channel-1"}
      "AQUBAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAY2BgjDM0fuPAwMAgwAQkGLa3Hbjh0DrjDBCcBQtcPh/M4LDtCIjJABaYfOodp8PhzM3GQAAWqGwI9XYIB/MhAq90Xk10WC6QBgJggdXf6vQdWgsQZtx+ep7doXU3QovGzqWLHdoXIbTw8FivdNi2AiEQrvdtt8PSmwiHndJlvOXgloZQ4Xd05iyHKZEIQ513nVntcOAfQgW7n42tw/kGHrgZ+pvL9B3aryAcFp27rM1hMT9YCwAua3WrHAEAAA==",
    ],

}

# Just enough here to test the most basic functionality of preflight calls
PREFLIGHT = {
  "detect(data('cpu.utilization') > 70).publish()" => [
      # DECODED {:channel=>"channel-1", :event=>"STREAM_START", :timestampMs=>1503966934573, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWCJ4JAgV0ff+OAQx6AQiFxJZm5qcUliboFvMUiFoamBsaWZmaWxiam5MURBZUEqxND8vJKi/BxdoPrixPRUJa5aANWVth94AAAA",

      # DECODED {:channel=>"channel-1", :event=>"JOB_START", :handle=>"DIW1ClNAcAA", :timestampMs=>1503966934651, :type=>"control-message", :timestamp=>2017-08-29 00:35:34 +0000}
      "AQEDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAq+ZSUFBKzkjMy0vNUVKwgrN1DZV0QFKpZal5JWAJL3+n+OAQx6AQiARQWUpOKljGxTPc0DnHzzHZ0REiV5KZm1pckphb4FsMUmBoamBsaWZmaWxiZmoIUVBZANGanJ9XUpSfowtUX5yYnqrEVQsASK/c7JEAAAA=",

      # DECODED {:channel=>"channel-1", :properties=>{:computationId=>"DIW1ClNAcAA", :dsname=>"value", :host=>"ip-10-0-1-249.us-west-2.compute.internal", :kubernetes_cluster=>"my-cluster", :kubernetes_role=>"worker", :plugin=>"signalfx-metadata", :plugin_instance=>"utilization", :sf_isPreQuantized=>true, :sf_key=>["plugin_instance", "kubernetes_cluster", "kubernetes_role", "computationId", "plugin", "dsname", "sf_metric", "host", "sf_originatingMetric"], :sf_metric=>"_SF_COMP_DIW1ClNAcAA_01-PUBLISH_METRIC", :sf_organizationID=>"CfhbPnRAcAM", :sf_originatingMetric=>"cpu.utilization", :sf_resolutionMs=>10000, :sf_singletonFixedDimensions=>["sf_metric"], :sf_type=>"MetricTimeSeries"}, :tsId=>"AAAAAEgCVmg", :type=>"metadata"}
      "AQQDAGNoYW5uZWwtMQAAAAAAAAAfiwgAAAAAAAAAbVPLbsIwELzzFYhzHBHUS3tLA6iRmpYCbQ9VFZmwBAvHjvwoL/HvtZ0QaINP2Z2Z9c56c+x0u71sjRkD2us+NN8o6HkWKgUvQSgC0qJHk7J8XpRaYUU4i5dONYw/g4i+hFkYOp0hLSXDBTj0B1MN5/yaS+WypERBH/VRgAZ3976WaAtSoYFfVQefMAWCYXoWbvTCxKBAphnV0oCuTLFH57BNFJxWLWy52FwYJdU5YQ6QJDd3rHaoAIWXWOG/nJQwqTDLqipaEUoOzviZJlcpkRMBbxozRQ7g5qGEhgu+gb1NfrVrejddeW0L3v+he40Jrxm1524zPgTJbOAmXSW5IIZrxCxPKrz7fWmwlliH6WycRq/JJL160bQfoMn743M8e0qT0XwaR1fmucgxq2cSD12NaLVeTNjUSJM/xFYLdt1K7d+eqgDJqbbJxO1e0DfnAktTh4LibEx2sBySApg0XFlP+srVlVG1L6uHrDqYG9UMhF1uQzm5hVeyXunQnlEefRR59Ss04mZTOqdfuO7aoz8DAAA=",
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
