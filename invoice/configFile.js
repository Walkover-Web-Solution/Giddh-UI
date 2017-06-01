    var page = require('webpage').create(),
        system = require('system'),
        fs = require('fs');

    page.paperSize = {
        format: 'A4',
        orientation: 'portrait',
        margin: {
            top: "1.5cm",
            bottom: "1cm"
        },
        footer: {
            height: "1cm",
            contents: phantom.callback(function (pageNum, numPages) {
                return '' +
                    '<div style="margin: 0 1cm 0 1cm; font-size: 0.65em">' +
                    '<table class="cfooter" cellpadding="0" cellspacing="0"><tr><td style="color: #000;font-weight: 500;">Walkover Web Solutions Private Limited</td></tr><tr><td>405-406 Capt. C. S. Naydu Arcade</td></tr><tr><td>10/2 Old Palasia, near Greater Kailash Hospital</td></tr><tr><td>Indore - 452001</td></tr><tr><td>(M.P.)</td></tr></table>      '
                    + pageNum + ' / ' + numPages + '</span>' +
                    '   </div>' +
                    '</div>';
            })
        }
    };

    // This will fix some things that I'll talk about in a second
    page.settings.dpi = "96";

    page.content = fs.read(system.args[1]);

    var output = system.args[2];

    window.setTimeout(function () {
        page.render(output, {format: 'pdf'});
        phantom.exit(0);
    }, 2000);