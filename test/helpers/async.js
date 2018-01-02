module.exports.test = function (message, functionToTest) {
    it(message, (done) => {
        functionToTest()
            .then(done)
            .catch(error => { done(error); });
    });
}