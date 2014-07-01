    var pairing_app = angular.module('pairing_app', ['timer']);

    pairing_app.controller('PairingCtrl', function ($scope, $timeout, $http) {
      
      $scope.step = 'connecting';
      $scope.panel ='loading';

      $scope.checkConnection = function(){
        
        $http.get("/pairing/check_connection/" + $scope.sessionId).success(function(response) {

          if('waiting' == response.status){
            
            $scope.step = response.status;
            $timeout(startTimer, 1000); 
            return;
          }

          $scope.step = 'disconnection';
          $scope.panel = 'retry';
        });
      };

      $scope.reconnect = function(){
        $scope.panel = 'loading';
        $http.get("/pairing/reconnect/" + $scope.deviceId).success(function(response) {
          $scope.sessionId = response.id;
          waitingForCheckConnect();
        });
      };

      $scope.$on('timer-tick', function (event, args) {
        $timeout(function (){
          if((args.millis % 10000) == 0){
            $http.get("/pairing/waiting/" + $scope.sessionId).success(function(response) {
              if(response.status == 'done'){
                $scope.step = 'done';
                $scope.panel = 'done';
              }
            });
          }
        });
      });

      $scope.$on('timer-stopped', function (event, args) {
        $scope.step = 'failure';
        $scope.panel = 'retry';
      });

      var waitingForCheckConnect = function(){
        $scope.step = 'connecting';
        $scope.panel = 'loading';
        $timeout($scope.checkConnection, 9500);   
      }
      
      var startTimer = function(){
        var timer = angular.element('#countdown-timer');
        $scope.$broadcast('timer-start');
      }

      waitingForCheckConnect();
    });
    