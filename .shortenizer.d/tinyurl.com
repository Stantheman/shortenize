basename: tinyurl.com
url: http://tinyurl.com
postpoint: /create.php
form:
	url: url
	alias: alias
answer_regex: '<blockquote><b>([^<]+)</b><div id="success"'

