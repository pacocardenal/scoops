
module.exports = {
    "get": function (req, res, next) {
        var query = { sql : "SELECT * FROM Posts WHERE status = 'true'" };
        req.azureMobile.data.execute(query)
            .then(function(result) {
                res.json(result);
            });
    }
}
