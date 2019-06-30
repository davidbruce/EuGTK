
-- En esta demostración, usamos el ini para controlar parte de la apariencia.
-- Esto quizás podría usarse para traducir subtítulos de botones y etiquetas 
-- en diferentes idiomas sin tener que tocar el código fuente del programa 
-- o volver a compilar!

-- Para ver otros idiomas, ejecute <u> eui multi xx </u>, donde xx es: 
-- en inglés, ge alemán, gk griego, fr francés, ru ruso, bn bengalí, hn hindi

-- traducido por Google translate

--! MainWindow.title = Probar el número de programa 2
--! MainWindow.border = 10

+ MainWindow.HelpCaption = Ayuda
+ MainWindow.HelpTitle = Acerca de este programa
+ MainWindow.HelpText = No hay mucho que contar, \nit es solo un programa \nok?

--! Button1.tooltip text = Haz clic aquí para salir
--! Button1.label = _Salir
--! Button1.image = gtk-quit
--! Button1.always-show-image = 1

--! Button2.tooltip text = Haz clic aquí para obtener ayuda
--! Button2.label = _Acerca de
--! Button2.image = gtk-about

--! Button3.tooltip text = Haga clic aquí para cambiar el color
--! Button3.label = _Fondo
--! Button3.image = style

+MainWindow.background=#71F459
MainWindow.size={448,650}
MainWindow.position={830,10}
