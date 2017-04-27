// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require turbolinks
//= require turbolinks-compatibility
//= require jquery.tablesorter

$.extend($.tablesorter.characterEquivalents, {
  'a' : '\u00e1\u00e0\u1ea3\u1ea1\u00e3\u0103\u1eaf\u1eb1\u1eb3\u1eb7\u1eb5\u00e2\u1ea5\u1ea7\u1ea9\u1ead\u1eab\u00e4\u0105\u00e5', // aáàảạãăắằẳặẵâấầẩậẫäąå
  'A' : '\u00c1\u00c0\u1ea2\u1ea0\u00c3\u0102\u1eae\u1eb0\u1eb2\u1eb6\u1eb4\u00c2\u1ea4\u1ea6\u1ea8\u1eac\u1eaa\u00c4\u0104\u00c5', // AÁÀẢẠÃĂẮẰẲẶẴÂẤẦẨẬẪÄĄÅ
  'd' : '\u0111', // dđ
  'D' : '\u0110', // DĐ
  'e' : 'e\u00e9\u00e8\u1ebb\u1eb9\u1ebd\u00ea\u1ebf\u1ec1\u1ec3\u1ec7\u1ec5\u00eb\u011b\u0119', // eéèẻẹẽêếềểệễëěę
  'E' : 'E\u00c9\u00c8\u1eba\u1eb8\u1ebc\u00ca\u1ebe\u1ec0\u1ec2\u1ec6\u1ec4\u00cb\u011a\u0118', // EÉÈẺẸẼÊẾỀỂỆỄËĚĘ
  'i' : 'i\u00ed\u00ec\u1ec9\u1ecb\u0129\u0130\u00ee\u00ef\u0131', // iíìỉịĩİîïı
  'I' : 'I\u00cd\u00cc\u1ec8\u1eca\u0128\u0130\u00ce\u00cfI', // IÍÌỈỊĨİÎÏI
  'o' : 'o\u00f3\u00f2\u1ecf\u1ecd\u00f5\u00f4\u1ed1\u1ed3\u1ed5\u1ed9\u1ed7\u01a1\u1edb\u1edd\u1edf\u1ee3\u1ee1\u00f6\u014d', // oóòỏọõôốồổộỗơớờởợỡöō
  'O' : 'O\u00d3\u00d2\u1ece\u1ecc\u00d5\u00d4\u1ed0\u1ed2\u1ed4\u1ed8\u1ed6\u01a0\u1eda\u1edc\u1ede\u1ee2\u1ee0\u00d6\u014c', // OÓÒỎỌÕÔỐỒỔỘỖƠỚỜỞỢỠÖŌ
  'u' : 'u\u00fa\u00f9\u1ee7\u1ee5\u0169\u01b0\u1ee9\u1eeb\u1eed\u1ef1\u1eef\u00fb\u00fc\u016f', // uúùủụũưứừửựữûüů
  'U' : 'U\u00da\u00d9\u1ee6\u1ee4\u0168\u01af\u1ee8\u1eea\u1eec\u1ef0\u1eee\u00db\u00dc\u016e' // UÚÙỦỤŨƯỨỪỬỰỮÛÜŮ
});

$.extend(true, $.tablesorter.defaults, {
  theme: 'blue',

  // hidden filter input/selects will resize the columns, so try to minimize the change
  widthFixed : true,

  widgets: ['zebra', 'filter'],

  // Enable use of the characterEquivalents reference
  sortLocaleCompare : true,

  // maintain a stable sort
  sortStable : true,

  // if false, upper case sorts BEFORE lower case
  ignoreCase : true,

  widgetOptions : {
    // class added to filtered rows (rows that are not showing); needed by pager plugin
    filter_filteredRow : 'filtered',

    // if true, filters are collapsed initially, but can be revealed by hovering over the grey bar immediately
    // below the header row. Additionally, tabbing through the document will open the filter row when an input gets focus
    // in v2.26.6, this option will also accept a function
    filter_hideFilters : false,

    // Set this option to false to make the searches case sensitive
    filter_ignoreCase : true,

    // global query settings ('exact' or 'match'); overridden by "filter-match" or "filter-exact" class
    filter_matchType : { 'input': 'exact', 'select': 'exact' },

    // a header with a select dropdown & this class name will only show available (visible) options within that drop down.
    filter_onlyAvail : 'filter-onlyAvail',

    // default placeholder text (overridden by any header "data-placeholder" setting)
    filter_placeholder : { search : '', select : '' },

    // Use the $.tablesorter.storage utility to save the most recent filters (default setting is false)
    filter_saveFilters : true,

    // Reset filter input when the user presses escape - normalized across browsers
    filter_resetOnEsc : true,

    // jQuery selector string of an element used to reset the filters
    filter_reset : 'button.reset',
  }
});
