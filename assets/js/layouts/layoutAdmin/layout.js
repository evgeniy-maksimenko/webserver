define(function(require) {
	'use strict';
  	var Backbone      	= require('backbone'),
        _             	= require('underscore'),
        layoutTemplate  = require('text!layouts/layoutAdmin/layoutTemplate.html'),
        router        	= require('router');

    function getData() {
            var data = 
                $.ajax({
                    url : '/api/treatments?condition=static',
                    type: "POST",
                    dataType: "json",
                    async: false,
                    success: function(data){}
                });
            return data;
        };

    return Backbone.View.extend({
    	template: _.template(layoutTemplate),

    	model: {
    		routes: router.routes
    	},

    	render: function() {
            var data  = getData();
            var arrayData =data.responseJSON;
            
    		this.$el.html(this.template(arrayData));

    		this.$el.find('content-placeholder').append(new this.content().render().el);
    		return this;
    	}
    })
});