    /**
     * @ngdoc object
     * @name pairing_app.PairingCtrl
     *
     * @description
     * Pariing status: {start: 0, waiting: 1, done: 2, offline: 3, failure: 4}
     */
    var pairing_app = angular.module('pairing_app', ['timer']);
    // pairing_app.directive('timer', ['$compile', function ($compile) {
    //   return  {
    //     restrict: 'A',
    //     scope: {
    //       countdownattr: '=countdown'
    //     }
    //   };
    // }]);
    pairing_app.controller('PairingCtrl', function ($scope, $timeout, $http) {
      
      $scope.step = 'connecting';
      $scope.panel = 'loading';
      $scope.watingUrl = '/pairing/waiting/';
      $scope.checkTimes = 0;
      $scope.timesLimit = 20;
      $scope.interval = 3000;
      $scope.formateSuffix = ".json";
      $scope.checkConnectionUrl = '/pairing/check_connection/';

      $scope.checkConnection = function(){
        $scope.disableBtn();
        $timeout(function(){

          var url = $scope.checkConnectionUrl  + $scope.sessionId + $scope.formateSuffix;
          $http.get(url).success(function(response) {
            switch(response.status){
              case 'offline':
                $scope.disconnectionStep();
                break;
              case 'waiting':
                $scope.step = response.status;
                $scope.panel = "waiting"
                $scope.disableBtn();
                $timeout(startTimer, 1000);
                break;
              case 'failure':
                $scope.canceledStep();
                break;
              case 'done':
                $scope.completedStep();
                break;
              case 'start':
                $scope.checkConnection();
                // if($scope.checkTimes <= $scope.timesLimit){
                //   $scope.checkConnection();
                //   break;
                // }
                // $scope.disconnectionStep();
                break;
            }
          });}, $scope.interval);
      };

      $scope.reconnect = function(){
        $scope.connectingStep();
        $http.get("/pairing/reconnect/" + $scope.deviceId + $scope.formateSuffix).success(function(response) {
          $scope.sessionId = response.id;
          $scope.waitingForCheckConnect();
        });
      };

      $scope.$on('timer-stopped', function (event, args) {
        $scope.failureStep();
      });

      $scope.waitingForCheckConnect = function(){

        if($scope.session.expire_in <= 0){
          $scope.failureStep();
          return;
        }

        $scope.connectingStep();
        $scope.checkTimes = 0;
        $timeout($scope.checkConnection, 9500);   
      }
      
      var startTimer = function(){
        
        var timer = angular.element('#countdown-timer');
        $scope.$broadcast('timer-set-countdown-seconds', $scope.session.expire_in);
        $scope.$broadcast('timer-start');
      }
      
      $scope.$on('timer-tick', function (event, args) {
        $timeout(function (){
          if((args.millis % 10000) == 0){
            $http.get($scope.checkConnectionUrl + $scope.sessionId + $scope.formateSuffix).success(function(response) {

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
        $scope.disableBtn();
      };

      $scope.failureStep = function(){
        $scope.step = 'failure';
        $scope.panel = 'retry';
      };

      $scope.disconnectionStep = function(){
        $scope.step = 'disconnection';
        $scope.panel = 'retry';
        $scope.enableBtn();
      };

      $scope.canceledStep = function(){
        $scope.step = 'canceled';
        $scope.panel = 'retry';
        $scope.enableBtn();
      };

      $scope.completedStep = function(){
        $scope.step = 'done';
        $scope.panel = 'done';
        $scope.enableBtn();
      };

      $scope.disableBtn = function(){
        var allButton = document.getElementsByTagName("a");
        for(var i=0; i<allButton.length; i++){
          var $thisBtn = allButton[i];
          var $thisUrl = $thisBtn.getAttribute('href');
          if ($thisUrl != "#"){
            $thisBtn.setAttribute('data-href', $thisBtn.getAttribute('href'));
            $thisBtn.setAttribute('href', '#');
          };
        };
      };

      $scope.enableBtn = function(){
        var allButton = document.getElementsByTagName("a");
        for(var i=0; i<allButton.length; i++){
          var $thisBtn = allButton[i];
          $thisBtn.setAttribute('href', $thisBtn.getAttribute('data-href'));
        };
      };

    });
    