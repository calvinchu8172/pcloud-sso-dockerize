// get devices data on search device page
var discoverer_app = angular.module('discoverer_app', []);
discoverer_app.controller('DeviceListCtrl', function ($scope, $http) {
  $scope.devices = JSON.parse(document.getElementById("device-data").getAttribute("data"));
  $scope.doClick = function() {

    $scope.devices = [];
    $http.get("/discoverer/index.json").success(function(response) {
      $scope.devices = response;
    });
  }
});
// get devices data - end
