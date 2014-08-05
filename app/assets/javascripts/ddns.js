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
  $scope.formateSuffix = ".json";

  $scope.checkStatus = function() {
    $timeout(function() {
      $scope.loadTimes++;

      // get ajax
      $http.get($scope.statusPath + $scope.session.id + $scope.formateSuffix, { cache: false}).success(function(response) {

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
