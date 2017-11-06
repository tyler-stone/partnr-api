describe('createUserCtrl', function() {
	beforeEach(module('partnr'));

	var $rootScope, $state, $controller, $httpBackend, $scope, 
		$location, requestHandler, controller, principal;

	beforeEach(inject(function(_$rootScope_, _$state_, _$controller_, 
		_$location_, _$httpBackend_, _principal_) {

		$rootScope = _$rootScope_;
		$state = _$state_;
		$controller = _$controller_;
		$httpBackend = _$httpBackend_;
		$location = _$location_;
		principal = _principal_;

		requestHandler = $httpBackend.when('GET', $rootScope.apiRoute + 'api/users/sign_in').respond({
			"csrfToken" : "54239" 
		});

		$scope = {};
		controller = $controller('CreateUserController', { $scope: $scope });
		$scope.acct = {
			email: "test@test",
			first_name: "test",
			last_name: "test",
			password: "test"
		};

		$location.url('/account/create');
		$rootScope.$digest();
	}));

	describe('when created', function() {
		beforeEach(function() {
			authRequestHandler = $httpBackend.when('POST', $rootScope.apiRoute + 'api/users/sign_in')
				.respond({
					"user" : { "first_name" : "Tyler", "last_name" : "Stone" },
					"csrfToken" : "4321"
				});

			principal.login('user','pass');
			$httpBackend.flush();
		});

		it('will relocate a logged in user to their respective home page', function() {
			$scope = {};
			controller = $controller('CreateUserController', { $scope: $scope });
			$rootScope.$digest();

			expect($state.current.name).to.be.equal('home');
		});
	});

	describe('validate', function() {
		it('will return true if all fields are entered', function() {
			expect($scope.validate()).to.be.equal(true);
		});

		it('will return false if a field is empty', function() {
			$scope.acct.email = "";
			expect($scope.validate()).to.be.equal(false);
		});
	});

	describe('doCreateUser', function() {
		it('will go to the home page when the page receives a valid response', function() {
			var createRequestHandler = $httpBackend.when('POST', $rootScope.apiRoute + 'api/users')
				.respond({ 
					"user" : { 
						"first_name" : "test", 
						"last_name" : "test" 
					}, 
					"csrfToken" : "54239" 
				});
			
			$scope.doCreateUser();
			$httpBackend.flush();

			expect($state.current.name).to.be.equal('login');	
		});

		it('will not go to the home page if there was an error', function() {
			var createRequestHandler = $httpBackend.when('POST', $rootScope.apiRoute + 'api/users')
				.respond({ 
					"error": "401"
				});
			$scope.doCreateUser();
			$httpBackend.flush();

			expect($state.current.name).to.be.equal('account_create');
		});
	});
});
