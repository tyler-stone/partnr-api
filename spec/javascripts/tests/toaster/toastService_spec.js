describe('toastService', function() {
  beforeEach(module('partnr'));

  var $compile, $rootScope, $httpBackend, element, toaster;

  beforeEach(inject(function(_$compile_, _$httpBackend_, _$rootScope_, _toaster_){
    $compile = _$compile_;
    $httpBackend = _$httpBackend_;
    $rootScope = _$rootScope_;
    toaster = _toaster_;

    $httpBackend.when('GET', $rootScope.apiRoute + 'api/users/sign_in')
      .respond({
        "csrfToken" : "54239" 
    });

    element = $compile("<toasts></toasts>")($rootScope);
    $rootScope.$digest();
  }));

  it('will properly show an informative popup', function() {
    toaster.info("testing");
    $rootScope.$digest();
    
    expect(element.html()).to.contain("info");
  });

  it('will properly show an error popup', function() {
    toaster.error("testing");
    $rootScope.$digest();
    
    expect(element.html()).to.contain("danger");
  });

  it('will properly show a warning popup', function() {
    toaster.warn("testing");
    $rootScope.$digest();
    
    expect(element.html()).to.contain("warning");
  });

  it('will properly show a success popup', function() {
    toaster.success("testing");
    $rootScope.$digest();
    
    expect(element.html()).to.contain("success");
  });
});