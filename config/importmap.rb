# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

# FullCalendar
pin "@fullcalendar/core", to: "https://cdn.skypack.dev/@fullcalendar/core@6.1.10"
pin "@fullcalendar/daygrid", to: "https://cdn.skypack.dev/@fullcalendar/daygrid@6.1.10"
pin "@fullcalendar/timegrid", to: "https://cdn.skypack.dev/@fullcalendar/timegrid@6.1.10"
pin "@fullcalendar/list", to: "https://cdn.skypack.dev/@fullcalendar/list@6.1.10"
pin "@fullcalendar/interaction", to: "https://cdn.skypack.dev/@fullcalendar/interaction@6.1.10"
pin "preact", to: "https://cdn.skypack.dev/preact@10.19.3"
pin "preact/compat", to: "https://cdn.skypack.dev/preact@10.19.3/compat"
