app = angular.module("cfTimeclockApp", [])

app.config ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).otherwise redirectTo: "/"

formatInputIntoTime  = (input) ->
  total = 0
  input = String(input)
  return total if !input

  seconds = retrieveNumber(input.slice(-2))
  minutes = retrieveNumber(input.slice(0, -2))
  total   = (minutes * 60) + seconds
  total

retrieveNumber = (input) ->
  result = parseInt(input)
  if result and angular.isNumber(result) and !isNaN(result)
    result
  else
    0

currentTime = -> new Date() / 1000

app.directive "timer", ->
  restrict: "A"
  scope:
    time: "=timer"
  link: ($scope) ->
    $scope.$watch 'time', (n, o) ->
      $scope.minutes = Math.floor(n / 60)
      $scope.seconds = (n % 60).toFixed(1)

  template: "<span class='timer'><span class='minutes'>{{ minutes }} min</span> </span><span class='seconds'>{{seconds}} </span></span>"


app.controller "MainCtrl", ($scope, $timeout) ->
  $scope.percentDone = ->
    $scope.workoutTime / $scope.totalWorkoutTime() * 100

  angular.element(document).bind 'keyup', (event) ->
    if event.keyCode == 13
      if $scope.canStart()
        $scope.start()
      else if $scope.canPause()
        $scope.pause()

  $scope.todos = [
    "Wait 10 seconds before starting workout",
    "Rounds",
    "Rest Between Rounds",
    "Sets",
    "Rest Between Sets",
    "Make Super Pretty",
    "Loud sounds at start of workout, at end of rounds/sets, and at end of workout (should be loud enough to hear over music)"
  ]

  $scope.canStart = ->
    $scope.paused || !$scope.inProgress
  $scope.canPause = ->
    $scope.inProgress && !$scope.paused
  $scope.canReset = ->
    $scope.paused || $scope.workoutDone

  $scope.start = ->
    if !$scope.inProgress
      $scope.startTime = currentTime()
    $scope.inProgress = true
    $scope.workoutDone = false

    if $scope.paused
      $scope.pausedLength += currentTime() - $scope.pausedAt
      $scope.paused = false

    updateInterval = 25

    fn = ->
      $scope.workoutTime = currentTime() - $scope.startTime - $scope.pausedLength

      if $scope.workoutTime >= $scope.totalWorkoutTime()
        $scope.inProgress = false
        $scope.workoutDone = true
        $scope.workoutTime = $scope.totalWorkoutTime()

      else if !$scope.paused
        $timeout fn, updateInterval

    $timeout fn, updateInterval

  $scope.pause = ->
    $scope.paused = true
    $scope.pausedAt = currentTime()

  $scope.reset = ->
    $scope.workoutDone = $scope.paused = $scope.inProgress = false
    $scope.startTime = null
    $scope.workoutTime = $scope.pausedLength = 0

  $scope.input = {}

  $scope.workoutTypes = [
    {title: "Custom",               sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 3 }
    {title: "Tabata",               sets: 4, setRest: 60, rounds: 8, roundRest: 10, roundLength: 20 }
    {title: "Fight Gone Bad",       sets: 3, setRest: 60, rounds: 5, roundRest: 0,  roundLength: 60 }
    {title: "Fight Gone Bad Champ", sets: 5, setRest: 60, rounds: 5, roundRest: 0,  roundLength: 60 }
    {title: "1 minutes",            sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 100 }
    {title: "3 minutes",            sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 300 }
    {title: "5 minutes",            sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 500 }
    {title: "7 minutes",            sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 700 }
    {title: "10 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 1000 }
    {title: "12 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 1200 }
    {title: "15 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 1500 }
    {title: "20 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 2000 }
    {title: "25 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 2500 }
    {title: "30 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 3000 }
    {title: "40 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 4000 }
    {title: "50 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 5000 }
    {title: "60 minutes",           sets: 1, setRest: 0,  rounds: 1, roundRest: 0,  roundLength: 6000 }
  ]

  # Sets the inputs from a predetermined workout type
  $scope.$watch "workoutType", (n) ->
    $scope.input = n if n

  $scope.timeLeft =       -> $scope.totalWorkoutTime() - $scope.workoutTime

  $scope.numberOfRounds = -> retrieveNumber($scope.input.rounds)
  $scope.numberOfSets   = -> retrieveNumber($scope.input.sets)

  $scope.lengthOfRound     = -> formatInputIntoTime($scope.input.roundLength)
  $scope.restBetweenRounds = -> formatInputIntoTime($scope.input.roundRest)
  $scope.restBetweenSets   = -> formatInputIntoTime($scope.input.setRest)

  $scope.totalWorkoutTime = ->
    rounds = $scope.lengthOfRound() * $scope.numberOfRounds()
    rest   = $scope.restBetweenRounds() * ($scope.numberOfRounds() - 1)
    sets   = $scope.numberOfSets()
    setsRest = $scope.restBetweenSets() * (sets - 1)
    ((rounds + rest) * sets) + setsRest

  $scope.reset()
  $scope.workoutType = $scope.workoutTypes[0]
  #$scope.start()

