name "td-agent"
description "Base role applied to td-agent nodes."
run_list(
  "recipe[apt]",
  "recipe[base::default]",
  "recipe[td-agent]"
)
override_attributes "td_agent" => {
                      "plugins" => [ "elasticsearch" ],
                      "platform" => "ubuntu"
                    }
