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
      $scope.watingUrl = '/pairing/waiting/';
      $scope.checkConnectionUrl = '/pairing/check_connection/';
      $scope.checkTimes = 0;
      $scope.timesLimit = 16; //16
      $scope.interval = 3500;

      $scope.checkConnection = function(){
        $timeout(function(){
          var url = $scope.checkConnectionUrl;
          $scope.checkTimes++;
          console.log("tick:" + $scope.checkTimes);
          if($scope.checkTimes < $scope.timesLimit){
            url = $scope.watingUrl;
          }   
          console.log("url:" + url);
          $http.get(url + $scope.sessionId).success(function(response) {
            switch(response.status){
              case 'offline':
                $scope.disconnectionStep();
                break;
              case 'waiting':
                $scope.step = response.status;
                $scope.panel = "waiting"
                $timeout(startTimer, 1000);
                break;
              case 'failure':
                $scope.canceledStep();
                break;
              case 'done':
                $scope.completedStep();
                break;
              case 'start':
                if($scope.checkTimes <= $scope.timesLimit){
                  $scope.checkConnection();
                  break;
                }
                $scope.disconnectionStep();
                break;
            }
          });}, $scope.interval);
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
        $scope.checkTimes = 0;
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
    