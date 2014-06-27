    var pairing_app = angular.module('pairing_app', ['timer']);

    pairing_app.controller('PairingCtrl', function ($scope, $timeout, $http) {
      
      $scope.step = 'connecting';
      $scope.panel ='loading';

      $scope.checkConnection = function(){
        console.log("check connection for device " + $scope.device_id);
        $http.get("/pairing/check_connection/" + $scope.sessionId).success(function(response) {

          if('waiting' == response.status){
            console.log("in step waiting");
            console.log(response);
            $scope.step = response.status

            $timeout(startTimer, 1000); 
            return;
          }

          console.log("device is offline");
          $scope.step = 'disconnection';
          $scope.panel = 'retry';
          
          console.log("check_connection:");
          console.log(response);
        });
      };

      $scope.reconnect = function(){
        $scope.panel = 'loading';
        console.log("reconnect");
        $http.get("/pairing/reconnect/" + $scope.deviceId).success(function(response) {
          console.log("index:");
          console.log(response);
          $scope.sessionId = response.id;
          waitingForCheckConnect();
        });
      };

      $scope.$on('timer-tick', function (event, args) {
        console.log("tick");
        $timeout(function (){
          if((args.millis % 10000) == 0){
            console.log('event.name = '+ event.name + ', timeoutId = ' + args.timeoutId + ', millis = ' + args.millis);
            $http.get("/pairing/waiting/" + $scope.sessionId).success(function(response) {
              console.log(response);
              if(response.status == 'done'){
                $scope.step = 'done';
                $scope.panel = 'done';
              }
            });
          }
        });
      });

      $scope.$on('timer-stopped', function (event, args) {
        console.log("stopped");
        $scope.step = 'failure';
        $scope.panel = 'retry';
      });

      var waitingForCheckConnect = function(){
        $scope.step = 'connecting';
        $scope.panel = 'loading';
        $timeout($scope.checkConnection, 9500);   
      }
      
      var startTimer = function(){
        console.log(angular.element('#countdown-timer'));
        var timer = angular.element('#countdown-timer');
        $scope.$broadcast('timer-start');
      }

      waitingForCheckConnect();


    });
    