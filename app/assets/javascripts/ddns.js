// check host name format when user entered 
function check_hostname(hostname, node_id) {
  var hostname_format = new RegExp("^([a-zA-Z0-9]+)$", "g");
  var error_node = document.getElementById(node_id);
  if (error_node) {
    if (hostname && hostname.value.match(hostname_format)) {
      if (!error_node.className.match("hidden")) {
        add_class(error_node, "hidden");
      }
      insert_value(hostname.value);
      trigger_submit_btn();
    } else {
      remove_class(error_node, "hidden");
      trigger_submit_btn();
    }
  }
}
// check host name - end

// set value of full domain
function insert_value(hostname) {
  var full_domain = document.getElementById("ddns_session_full_domain");
  var domain_name = document.getElementById("domain-name");
  if (full_domain && domain_name) {
    full_domain.value = hostname + domain_name.innerHTML;
  }
}
// set value of full domain - end
