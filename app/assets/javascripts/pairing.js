    /**
     * @ngdoc object
     * @name pairing_app.PairingCtrl
     *
     * @description
     * Pariing status: {start: 0, waiting: 1, done: 2, offline: 3, failure: 4}
     */
    var pairing_app = angular.module('pairing_app', ['timer']);
    pairing_app.controller('PairingCtrl', function ($scope, $timeout, $http) {
      
      $scope.step = 'connecting';
      $scope.panel ='loading';

      $scope.checkConnection = function(){
        
        $http.get("/pairing/check_connection/" + $scope.sessionId).success(function(response) {

          switch(response.status){
            case 'offline':
              $scope.disconnectionStep();
              break;
            case 'waiting':
              $scope.step = response.status;
              $timeout(startTimer, 1000);
              break;
            case 'failure':
              $scope.canceledStep();
              break;
            default:
              //don't do anything, keep polling;
          }
        });
      };

      $scope.reconnect = function(){
        $scope.connectingStep();
        $http.get("/pairing/reconnect/" + $scope.deviceId).success(function(response) {
          $scope.sessionId = response.id;
          $scope.waitingForCheckConnect();
        });
      };

      $scope.$on('timer-stopped', function (event, args) {
        $scope.failureStep();
      });

      $scope.waitingForCheckConnect = function(){
        $scope.connectingStep();
        $timeout($scope.checkConnection, 9500);   
      }
      
      var startTimer = function(){
        var timer = angular.element('#countdown-timer');
        $scope.$broadcast('timer-start');
      }
      
      $scope.$on('timer-tick', function (event, args) {
        $timeout(function (){
          if((args.millis % 10000) == 0){
            $http.get("/pairing/waiting/" + $scope.sessionId).success(function(response) {

              switch(response.status){
                case 'done':
                  $scope.$broadcast('timer-stop');
                  $scope.completedStep();
                  break;
                case 'failure':
                  $scope.canceledStep();
                  break;
              }
            });
          }
        });
      });

      $scope.connectingStep = function(){
        $scope.step = 'connecting';
        $scope.panel = 'loading';
      };

      $scope.failureStep = function(){
        $scope.step = 'failure';
        $scope.panel = 'retry';
      };

      $scope.disconnectionStep = function(){
        $scope.step = 'disconnection';
        $scope.panel = 'retry';
      };

      $scope.canceledStep = function(){
        $scope.step = 'canceled';
        $scope.panel = 'retry';
      };

      $scope.completedStep = function(){
        $scope.step = 'done';
        $scope.panel = 'done';
      };

    });
    