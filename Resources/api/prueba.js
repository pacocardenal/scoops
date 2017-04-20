
module.exports = {
    "get": function (req, res, next) {
        var date = { currentTime: Date.now() };
        console.log('*********');
        console.log(req.query.miparametro);
        res.status(200).type('application/json').send(date);
    }
}
