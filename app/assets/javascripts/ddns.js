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

// check DDNS session status
var ddns_app = angular.module('ddns_app', ['timer']);

ddns_app.controller('DdnsCtrl', function($scope, $http, $timeout, $window) {
  $scope.session;
  $scope.failurePath = "/ddns/failure/";
  $scope.statusPath = "/ddns/status/";
  $scope.step = "loading";
  $scope.loadTimes = 0;
  $scope.timesLimit = 16;
  $scope.interval = 3500;

  $scope.checkStatus = function() {
    $timeout(function() {
      $scope.loadTimes++;

      // get ajax
      $http.get($scope.statusPath + $scope.session.id, { cache: false}).success(function(response) {

        // display success information when status was changed to success
        if(response.status == "success") {
          $scope.step = "success";
          $scope.session = response;
          return;

        // redirect to setting page and set error message when timeout or failure
        } else if(response.status == "failure" || $scope.loadTimes >= $scope.timesLimit) {
          $window.location.href = $scope.failurePath + $scope.session.device_id;
        } else {
          $scope.checkStatus();
        }
      });

    }, $scope.interval);

  };
});
// check DDNS session status - end
