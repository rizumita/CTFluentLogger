name "elasticsearch"
description "Base role applied to elasticsearch nodes."
run_list(
  "recipe[java]",
  "recipe[elasticsearch]"
)
override_attributes "java" => {
                        "install_flavor" => "openjdk",
                        "jdk_version" => "7" }
