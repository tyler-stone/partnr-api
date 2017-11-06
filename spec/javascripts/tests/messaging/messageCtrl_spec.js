describe('MessageController', function() {
	beforeEach(module('partnr'));

	var $controller;

	beforeEach(inject(function(_$controller_) {
		$controller = _$controller_;
	}));

	describe('$scope.messages', function() {
		it('receives messages from api', function() {
			var $scope = {};
			var controller = $controller('MessageController', { $scope : $scope });
			expect($scope.messages).to.exist;
		});
	});
});