// get devices data on search device page
var device_list_app = angular.module('device_list_app', []);
device_list_app.controller('DeviceListCtrl', function ($scope, $http) {
  $scope.devices = JSON.parse(document.getElementById("device-data").getAttribute("data"));
  $scope.doClick = function() {

    $scope.devices = [];
    $http.get("/discoverer/index.json").success(function(response) {
      $scope.devices = response;
    });
  }
});
// get devices data - end

// check mac address format when user entered 
function check_mac_address(mac_address, node_id) {
  var address_format = new RegExp("^([0-9a-f]{2}:){5}[0-9a-f]{2}$", "i");
  var error_node = document.getElementById(node_id);
  if (error_node) {
	  if (mac_address && mac_address.value.match(address_format)) {
	  	if (!error_node.className.match("hidden")) {
	  		add_class(error_node, "hidden");
	  	}
	  } else {
	  	remove_class(error_node, "hidden");
	  }
	}
}
// check mac address - end