# OnTheClock en la mina

## Introducción

Una gran empresa minera le ha pedido que desarrolle una solución de seguimiento del tiempo de trabajo para losmineros que trabajan para ellos bajo tierra. La aplicación se llamará OnTheClock y utilizará Ruby On Rails.

Los mineros ingresan a su lugar de trabajo a través de puertas equipadas con lectores de tarjetas magnéticas.Cada empleado tiene una tarjeta magnética personal con su identidad. Tan pronto como los empleados ingresan alas instalaciones a través de las puertas, comienza su tiempo de trabajo remunerado. Cuando salen de lasinstalaciones por las puertas, su tiempo de trabajo remunerado se detiene. La maquinaria de puertas llama a laAPI REST en la aplicación OnTheClock cada vez que una persona entra o sale. El endpoint llamado es POST /events y abajo hay un ejemplode un .JSON que se envió:

```
{
	"employee_id": "999",
	"timestamp": 123456789,
	"kind": "in|out"
}
```

El `employee_id` es un identificador único de un empleado que causó este evento. La `timestamp` es una marca detiempo UNIX que contiene la hora del evento. El `kind` es una cadena igual a `"in"`  o `"out"`  e indica si se trata de unevento de entrada o de salida. Cuando se llama al endpoint, la aplicación debe guardar el evento en la base de datosSQLite para reportes posteriores.

El Departamento de Nómina está interesado en los eventos de la puerta porque necesitan saber cuánto tiempotrabajó cada empleado en un período de tiempo determinado. Por lo tanto, la aplicación necesita exponer un `GET /reports/{employee_id}/{from}/{to}` endpoint, donde el `employee_id`  es un identificador de empleado único delempleado, para quien se debe generar el reporte. Mientras que `from` y `to` son las fechas de cadena en el siguienteformato: `YYYY-MM-DD`, indicando el lapso de tiempo del reporte. En respuesta, la aplicación debe generar unreporte (basado en los eventos de entrada almacenados) en el siguiente formato:

```
{
	"employee_id": "9999", 
	"from": "YYYY-MM-DD,
	"to": "YYYY-MM-DD", 
	"working_hrs": 999.99,
	"problematic_dates": ["YYYY-MM-DD", "YYYY-MM-DD", "YYYY-MM-DD"]
}
```

Donde:

`employee_id` - el identificador del empleado según los parámetros de entrada,
`from` - la fecha de inicio del reporte según los parámetros de entrada,
`to` - la fecha de finalización del reporte según los parámetros de entrada, 
`working_hrs` - el número total de horas, durante las cuales este empleado trabajó en el período solicitado(un número de punto flotante redondeado a dos lugares decimales),
`problematic_dates` -  contiene todas las fechas en las que hay una inconsistencia en los eventos de entrada/salida. Ocurre una inconsistencia si hay un evento de "in"  sin un evento de `"out"` correspondiente o si hay un evento de `"out"` sin un evento de `"in"`  correspondiente.

Las inconsistencias ocurren porque a veces el sistema puede fallar y no registrar ningún evento o el empleadopuede ingresar o salir de la mina sin presionar su tarjeta en el lector de tarjetas magnéticas. Considere lossiguientes eventos generados por un empleado:

```
IN - 2019-01-01 08:00,
IN - 2019-01-02 08:00 -> no out event on the previous day (2019-01-01 is problematic),
OUT - 2019-01-02 16:00,
IN - 2019-01-03 08:00 -> no out event that day (2019-01-03 is problematic),
OUT - 2019-01-04 16:00 -> no in event that day (2019-01-04 is problematic).

La secuencia de eventos anterior debe proporcionar lo siguiente problematic_dates: [2019-01-01, 2019-01-03,2019-01-04].
```

Cuando una fecha se considera problemática, no agrega ningún tiempo laboral al reporte.La maquinaria de las puertas y la red no son perfectas y, a veces, la aplicación obtiene eventos duplicados. Un evento se considera duplicado si existe otro evento con el mismo `employee_id`  y `kind`, y la diferencia entre el `timestamps` es menos de 1 segundo. El endpoint de generación de reportes debe conocer los duplicados y no debeinformar las fechas con eventos duplicados como problemáticas.Por ejemplo, debería poder manejar casos como el siguiente:

```
IN - 2019-01-01 08:00:00,
IN - 2019-01-01 08:00:01 -> it is a duplicate caused by problems with gate machinery,
OUT - 2019-01-01 16:00.
```

En tales casos, no queremos que 2019-01-01 se informe como problemático.

# The task

1. Implemente los dos puntos finales descritos anteriormente.
2. Hay todas las clases y archivos necesarios creados para usted. No necesita crear ningún archivo nuevo.
3. Los eventos deben almacenarse y leerse utilizando el modelo `Event` `Active Record`. La migración ya ha tenido lugar. Los eventos duplicados (como se describe arriba) también deben almacenarse y deben manejarse durante la generación del informe.
4. La lógica de generación de informes debe implementarse en las clases `ReportGenerator` y `Report`.
5. Hay un conjunto mínimo de pruebas de integración que solo cubren los casos básicos. Es su trabajo descubrir todos los casos extremos y cubrirlos con pruebas. Al final del día, su solución será verificada minuciosamente por nuestro software de verificación.
6. Los puntos finales deben requerir todos los parámetros de entrada especificados anteriormente. Si faltan parámetros o tienen valores no válidos, los puntos finales deben responder con la `solicitud incorrecta HTTP 400`.
7. Hay `TODO` en el código para ayudarlo en la implementación.
