describe('loginCtrl', function() {
	beforeEach(module('partnr'));

	var $rootScope, $state, $scope, $controller, $httpBackend, $location;

	beforeEach(inject(function(_$rootScope_, _$state_, _$controller_, _$location_, _$httpBackend_) {
		$rootScope = _$rootScope_;
		$state = _$state_;
		$controller = _$controller_;
		$location = _$location_;
		$httpBackend = _$httpBackend_;

		$scope = {};

		$httpBackend.when('GET', $rootScope.apiRoute + 'api/users/sign_in')
			.respond({
				"csrfToken" : "54239" 
			});

		$location.url('/account/login');
		$rootScope.$digest();
	}));

	describe('doLogin', function() {
		it('will go to the home page when a user logs in', function() {
			var controller = $controller('LoginController', { $scope: $scope });
			$scope.email = 'tylerstonephoto@gmail.com';
			$scope.password = 'password';

			$httpBackend.when('POST', $rootScope.apiRoute + 'api/users/sign_in')
				.respond({ 
					"user" : { 
						"first_name" : "Tyler", 
						"last_name" : "Stone" 
					}, 
					"csrfToken" : "54239" 
				});

			$scope.doLogin();
			$httpBackend.flush();

			console.log($state.current.name);
			expect($state.current.name).to.be.equal('home');
		});

		it('will not go to the home page when a user does not get logged in', function() {
			var controller = $controller('LoginController', { $scope: $scope });
			$scope.email = 'dog';
			$scope.password = 'password';

			$httpBackend.when('POST', $rootScope.apiRoute + 'api/users/sign_in')
				.respond({ 
					"error": "401"
				});

			$scope.doLogin();
			$httpBackend.flush();

			expect($state.current.name).to.be.equal('login');
		});
	});
});
