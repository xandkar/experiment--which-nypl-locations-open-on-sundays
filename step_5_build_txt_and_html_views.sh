#! /bin/bash

set -e

cat uri-api-response-pretty.json \
| jq '
    .locations
    | map(select(
            ( .hours.regular
            | map(select(
                   .day == "Sun." and .open != null
               ))
            | length
            ) > 0
        ))
    | map(
        { name           : .name
        , street_address : .street_address
        , locality       : .locality
        , region         : .region
        , phone          : .contacts.phone
        , hours          : .hours.regular
        , images         : .images
        })
    ' \
| tee \
    >(nodejs -e '
        const l = console.log
        process.stdin.setEncoding("utf8");
        var data = "";
        process.stdin.on("readable", () => {
          const chunk = process.stdin.read();
          if (chunk !== null) {
              data += chunk
          }
        });
        process.stdin.on("end", () => {
            keys =
                [ "name"
                , "street_address"
                , "locality"
                , "region"
                , "phone"
                , "hours"
                , "images"
                ];
            l("<html>")
            l("<head>")
            l("<title>Selected NYPL locations</title>")
            l("</head>")
            l("<body>")
            l("<table border=1>")
            l("<tr>")
            keys.forEach(k => {
                if (k === "images") {
                    l("<th>photo exterior</th><th>photo interior</th>")
                } else {
                    l("<th>", k, "</th>")
                }
            });
            l("</tr>");
            JSON.parse(data).forEach(location => {
                l("<tr>")
                keys.forEach(k1 => {
                    if (k1 === "hours") {
                        l("<td>");
                        l("<table border=0>");
                        columns = ["day", "open", "close"];
                        l("<tr>");
                        columns.forEach(column => l("<th>", column, "</th>"));
                        l("</tr>");
                        location[k1].forEach(day => {
                            l("<tr>");
                            columns.forEach(column => l("<td>", day[column], "</td>"));
                            l("</tr>");
                        });
                        l("</table>")
                        l("</td>");
                    } else if (k1 === "images") {
                        ["exterior", "interior"].forEach(k2 => {
                            uri = location[k1][k2];
                            uri_parts = uri.split("/");
                            filename = uri_parts[uri_parts.length - 1];
                            filepath = ["images", filename].join("/")
                            l(
                                "<td><a href=\""
                                + filepath
                                + "\"><img width=100 height=100 src=\""
                                + filepath
                                + "\"></a></td>"
                            );
                        })
                    } else {
                        l("<td>", location[k1], "</td>")
                    }
                });
                l("</tr>");
            });
            l("</table>")
            l("</body>")
            l("</html>")
        });
    ' \
    > open_on_sundays.html \
    ) \
| jq -r \
    '
    map(
        [ .name
        , .street_address
        , .locality
        , .region
        , .phone
        ] | @sh
    )
    '
