var setup,wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7;setup=function(e){var r,n,t,c,o,s,u,i,a,p,l,f,d,g,v,j,E,h,m,q,y,P,x,F,S,T,z,w,A,J,K,O,C;S=(new Date).getTime(),g=require("fs"),a=require("crypto"),P=require("mkdirp"),j=e.document.querySelector("head"),u=e.document.querySelector("body"),c=e.document.querySelector("#app"),t="./app/",o="",s=null,q="",m="",y=null,x="",z=null,l=!1,h=!1,T=function(e){return console.log("### EXCEPTION: "+e),console.log(e.stack),!0},process.on("uncaughtException",T),e.onerror=T,n=function(e,r,n){var t;return t=n||function(){return!0},function(){var r,n,c,o;return n=g.readFileSync(e,{encoding:"utf8"}),e.indexOf("enc")!==-1?(r=a.createDecipher(wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7.algorithm,wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7.password),c=r.update(n,"base64","utf8"),c+=r.final("utf8")):c=n,o=document.createElement("script"),o.type="text/javascript",o.innerHTML=c,u.appendChild(o),t()}},r=function(e,r,n,t){var c;return c=t||function(){return!0},function(t){var o,s;return o=t||function(){return!0},n&&(r="file://"+r),s=document.createElement("link"),s.rel="stylesheet",s.type="text/css",s.href=r,e.appendChild(s),c(o)}},d=function(e){var r;return r=e.lastIndexOf("."),d=e.substring(r+1)},v=function(e,r){var n,t;n=d(e);for(t in r)if(n===r[t])return!0;return!1};try{if(q=process.env.ETTHOME?process.env.ETTHOME:process.platform==="win32"?process.env.USERPROFILE:process.env.HOME,m=q+"/.elevatorscreen/",g.existsSync(m)||P(m,function(e){return e&&console.log("Could not create directory: "+m),!0}),s=require(t+"js/app-version.json"),l?(x=m,h=!0):(x=t,h=!1),o=require(x+"js/app-lazyload.json")){if(F=function(){return APP.settings.head=j,APP.settings.body=u,APP.settings.appdom=c,APP.settings.$app=jQuery(app),APP.settings.root=x,APP.settings.version=s.version,APP.ui.init(),!0},p=function(e){var r;return r=e||function(){return!0},r()},o.js&&o.js!==[]&&o.js.length>0)for(o.js.reverse(),O=o.js,w=0,J=O.length;J>w;w++)E=O[w],F=n(E,h,F);if(o.css&&o.css!==[]&&o.css.length>0)for(o.css.reverse(),C=o.css,A=0,K=C.length;K>A;A++)i=C[A],p=r(j,i,h,p);"function"==typeof F?p(function(){return setTimeout(F,500),!0}):p()}return e.setup={version:s.setup,startTime:S,current:l,localhome:q,localcore:m,root:x,uncaughtException:T,addCSSFile:r},!0}catch(b){return f=b,T(f)}},wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7={algorithm:"aes-256-cbc",password:"√∞¨≠¢§¶•ELEVATOR£≤˜˜≥£®´ß∂ƒ∆©˚¡•¡¬SCR33N"};