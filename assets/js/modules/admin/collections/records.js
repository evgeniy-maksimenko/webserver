define([

	'backbone'

],function(Backbone){

	var Records = Backbone.Collection.extend({
		initialize: function(date_from, date_to) {
			if(date_from && date_to)
            {
                this.url = '/api/find_all_records?date_from='+date_from+'&date_to='+date_to
            }
            else
            {
                this.url = '/api/find_all_records'
            }
		}
	}) ;

	return Records;

});