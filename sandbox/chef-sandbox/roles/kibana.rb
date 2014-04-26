name "kibana"
description "Base role applied to kibana nodes."
run_list(
  "recipe[kibana::default]",
  "recipe[kibana::apache]",
)
default_attributes "kibana" => {
                      "version" => "3",
                    }

