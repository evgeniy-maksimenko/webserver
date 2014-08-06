define(function(require) {
	'use strict';
	var Backbone 	= require('backbone'),
		_ 			= require('underscore'),
		indexTemplate = require('text!modules/admin/templates/indexTemplate.html'),
		Layout = require('layouts/layoutAdmin/layout');

		var IndexPage = Backbone.View.extend({
			template: _.template(indexTemplate),
			render: function() {
				this.$el.html(this.template(this));
				return this;
			}
		});

		return Layout.extend({
			content: IndexPage
		})
});