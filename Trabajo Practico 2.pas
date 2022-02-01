program trabajo_practico_2;

uses crt;

type
	cadena8=string[8];
	regcuenta = Record
		numero_cuenta: Integer;
		apellido: String[50];
		nombre: String[50];
		dni: cadena8;
		tipo_cuenta: byte;
		saldo: Real;
		sw: boolean;
	end;
	
	regcajero = Record
		numero_cajero: integer;
		ubicacion: String[50];
		cant_mov:longint;
	end;
	
	cuentas=file of regcuenta;
	cajeros=file of regcajero;
	vectorcajero=array[1..100]of longint;
	vectorcuenta=array[1000..1700]of real;
	
var
	movi:text;
	cuenta:cuentas;
	cajero:cajeros;
	v:vectorcajero;
	v2:vectorcuenta;
	
procedure inicializar_vector(var v:vectorcajero);                //inicializo contador para los movimientos de los cajeros
var
	i:byte;
begin
	for i:=1 to 100 do
		v[i]:=0;
end;

procedure inicializar_vector2(var v2:vectorcuenta);              //inicializo matriz para actualizar archivo de acceso directo
var
	i:word;
begin
	for i:=1000 to 1700 do
		v2[i]:=0;
end;

procedure mayor_cajero(var v:vectorcajero;var mayor:longint;var cabina:byte);
var
	i:byte;
begin
	mayor:=v[1];
	cabina:=1;
	for i:=2 to 100 do
		if (v[i]>mayor) then
			begin
				mayor:=v[i];
				cabina:=i;
			end;			
end;			

procedure corte(var movi:text;var v:vectorcajero;var v2:vectorcuenta);    //corte de control
var
	nro_cuenta,nro_cajero,ano,mes,dia,tipo_mov,cuentant:integer;
	monto:real;
	cabina:byte;
	mayor:longint;
begin
	textcolor(10);
	reset(movi);
	readln(movi,nro_cuenta,ano,mes,dia,nro_cajero,tipo_mov,monto);
	cuentant:=nro_cuenta;
	while not eof(movi) do
		begin
			while (nro_cuenta=cuentant) and not eof(movi) do
				begin
					v[nro_cajero]:=v[nro_cajero]+1;
					if (tipo_mov=1) then 
						v2[nro_cuenta]:=v2[nro_cuenta]+monto;
					if (tipo_mov=2) then
						v2[nro_cuenta]:=v2[nro_cuenta]-monto;
					readln(movi,nro_cuenta,ano,mes,dia,nro_cajero,tipo_mov,monto);
				end;			
			if (nro_cuenta<>cuentant) then
				begin
					gotoxy(2,2);writeln('Cuenta: ',cuentant);
					gotoxy(2,4);writeln('Saldo total anual: ',v2[cuentant]:12:2);
					cuentant:=nro_cuenta;
					readkey;
					clrscr;
				end;
		end;
	v[nro_cajero]:=v[nro_cajero]+1;
	if (tipo_mov=1) then 
		v2[nro_cuenta]:=v2[nro_cuenta]+monto;
	if (tipo_mov=2) then
		v2[nro_cuenta]:=v2[nro_cuenta]-monto;
	gotoxy(2,2);writeln('Cuenta: ',nro_cuenta);
	gotoxy(2,4);writeln('Saldo total anual: ',v2[nro_cuenta]:12:2);					
	readkey;
	clrscr;
	close(movi);
	mayor_cajero(v,mayor,cabina);
	gotoxy(2,2);writeln('El cajero que realizo mayor cantidad de movimientos fue el: ',cabina);
	gotoxy(2,4);writeln('Realizo: ',mayor,' movimientos');
	readkey;
end;

procedure actualizar_cajeros(var cajero:cajeros;var v:vectorcajero);		//actualizo los cajeros
var
	i:byte;
	un_cajero:regcajero;
begin
	textcolor(10);
	reset(cajero);
	for i:=1 to 100 do
		begin
			if (v[i]<>0) then
				begin
					seek(cajero,i-1);
					read(cajero,un_cajero);
					seek(cajero,i-1);
					un_cajero.cant_mov:=un_cajero.cant_mov+v[i];
				end;
		end;
	close(cajero);
	gotoxy(2,2);writeln('Actualizacion exitosa');
	readkey;
	clrscr;
end;					

procedure actualizar_cuentas(var cuenta:cuentas;var v2:vectorcuenta);		//actualizo las cuentas
var
	i:word;
	una_cuenta:regcuenta;
begin
	textcolor(10);
	reset(cuenta);
	for i:=1000 to 1700 do
		begin
			if (v2[i]<>0) then
				begin
					seek(cuenta,i-1000);
					read(cuenta,una_cuenta);
					seek(cuenta,i-1000);
					una_cuenta.saldo:=una_cuenta.saldo+v2[i];
				end;
		end;			
	close(cuenta);
	gotoxy(2,2);writeln('Actualizacion exitosa');
	readkey;
	clrscr;
end;	

procedure consultas(var cuenta:cuentas);		//consultas
var
	buscar:integer;
	una_cuenta:regcuenta;
begin
	reset(cuenta);
	textcolor(14);
	gotoxy(1,1);writeln('==Consultas==');
	textcolor(10);
	gotoxy(1,3);writeln('Ingrese el numero de la cuenta que desea consultar');
	readln(buscar);
	buscar:=buscar-1000;
	if (buscar<0) or (buscar>=filesize(cuenta)) then
		begin
			textcolor(12);
			writeln('La cuenta no existe');
			readkey;
		end	
	else	
		begin
			seek(cuenta,buscar);
			read(cuenta,una_cuenta);
			clrscr;
			if (una_cuenta.sw=true) then
				begin
				textcolor(14);
				gotoxy(1,1);writeln('==Consultas==');
				textcolor(10);
				gotoxy(1,3);writeln('Numero de cuenta: ',una_cuenta.numero_cuenta);
				writeln('Apellido: ',una_cuenta.apellido);
				writeln('Nombre: ',una_cuenta.nombre);
				writeln('DNI: ',una_cuenta.dni);
				writeln('Tipo de cuenta: ',una_cuenta.tipo_cuenta);
				writeln('Saldo: ',una_cuenta.saldo:12:2);
				readkey;
				end
			else
				begin
					textcolor(10);
					writeln('La cuenta ingresada fue dada de baja');
				end;	
			readkey;
		end;
end;

function posicion(var cuenta:cuentas;n:cadena8):integer;		//buscar si existe el registro con el dni
var
	registro:regcuenta;
	hallado:boolean;
begin
	hallado:=false;
	seek(cuenta,0);
	while not eof(cuenta) and not hallado do
		begin
			read(cuenta,registro);
			hallado:=(registro.dni)=n;
		end;
	if hallado then
		posicion:=filepos(cuenta)-1		//si lo hallo devuelve la posicion donde lo hallo
	else
		posicion:=-1;					//si no lo hallo devuelve -1
end;		

procedure altas(var cuenta:cuentas);		//altas
var
	i:integer;
	nuevo,regexistente:regcuenta;
begin
	textcolor(14);
	gotoxy(1,1);writeln('==Altas==');
	reset(cuenta);
	textcolor(12);
	gotoxy(1,22);writeln('Presione n para salir');
	while upcase(readkey)<>'N' do
		begin
			clrscr;
			textcolor(14);
			gotoxy(1,1);writeln('==Altas==');
			textcolor(10);
			gotoxy(1,3);writeln('Ingrese la nueva cuenta');
			with nuevo do
				begin
					gotoxy(1,5);writeln('Ingrese apellido');
					readln(apellido);
					gotoxy(1,7);writeln('Ingrese nombre');
					readln(nombre);
					gotoxy(1,9);writeln('Ingrese DNI');
					readln(dni);
					gotoxy(1,11);writeln('Ingrese tipo de cuenta');
					readln(tipo_cuenta);
					gotoxy(1,13);writeln('Ingrese saldo');
					readln(saldo);
					sw:=true;
				end;
			i:=posicion(cuenta,nuevo.dni);	
			if (i=-1) then
				begin
					i:=filesize(cuenta);
					nuevo.numero_cuenta:=i+1000;
					seek(cuenta,i);
					write(cuenta,nuevo);
				end
			else
				begin
					seek(cuenta,i);
					read(cuenta,regexistente);
					if (regexistente.sw) then
						begin
							clrscr;
							textcolor(14);
							gotoxy(1,1);writeln('==Altas==');
							textcolor(10);
							gotoxy(1,3);writeln('El registro existe y esta dado de alta');
						end
					else
						write(cuenta,nuevo);
				end;
			textcolor(12);	
			gotoxy(1,22);writeln('Presione n para salir');
		end;
	close(cuenta);
end;		

procedure bajas(var cuenta:cuentas);
var
	buscar:integer;
	borrar:regcuenta;
begin
	textcolor(14);
	gotoxy(1,1);writeln('==Bajas==');
	reset(cuenta);
	textcolor(12);
	gotoxy(1,22);writeln('Presione n para salir');
	while upcase(readkey)<>'N' do
		begin
			clrscr;
			textcolor(14);
			gotoxy(1,1);writeln('==Bajas==');
			textcolor(10);
			gotoxy(1,3);writeln('Ingrese el numero de cuenta que desea dar de baja');
			readln(buscar);
			buscar:=buscar-1000;
			if (buscar<0) or (buscar>=filesize(cuenta)) then
				begin
					textcolor(12);
					writeln('La cuenta no existe');
					readkey;
				end	
			else
				begin
					seek(cuenta,buscar);
					read(cuenta,borrar);
					if (borrar.sw=true) then
						begin
							borrar.sw:=false;
							seek(cuenta,buscar);
							write(cuenta,borrar);
						end
					else
						begin
							writeln('La cuenta esta dada de baja');
							readkey;
						end;
				end;
			textcolor(12);	
			gotoxy(1,22);writeln('Presione n para salir');
		end;
	close(cuenta);
end;			
			
procedure modificaciones(var cuenta:cuentas);
var
	buscar:integer;
	modificar:regcuenta;
begin
	textcolor(14);
	gotoxy(1,1);writeln('==Modificaciones==');
	reset(cuenta);
	textcolor(12);
	gotoxy(1,22);writeln('Presione n para salir');
	while upcase(readkey)<>'N' do
		begin
			clrscr;
			textcolor(14);
			gotoxy(1,1);writeln('==Modificaciones==');
			textcolor(10);
			gotoxy(1,3);writeln('Ingrese el numero de cuenta que desea modificar');
			readln(buscar);
			buscar:=buscar-1000;
			if (buscar<0) or (buscar>=filesize(cuenta)) then
				begin
					textcolor(12);
					writeln('La cuenta no existe');
					readkey;
				end	
			else
				begin
					with modificar do
						begin
							gotoxy(1,5);writeln('Ingrese apellido');
							readln(apellido);
							gotoxy(1,7);writeln('Ingrese nombre');
							readln(nombre);
							gotoxy(1,9);writeln('Ingrese DNI');
							readln(dni);
							gotoxy(1,11);writeln('Ingrese tipo de cuenta');
							readln(tipo_cuenta);
							gotoxy(1,13);writeln('Ingrese saldo');
							readln(saldo);
							sw:=true;
						end;
					seek(cuenta,buscar);
					write(cuenta,modificar);
				end;	
			textcolor(12);	
			gotoxy(1,22);writeln('Presione n para salir');
		end;
	close(cuenta);
end;	

procedure menu(var movi:text;var cuenta:cuentas;var cajero:cajeros;var v:vectorcajero;var v2:vectorcuenta);		//menu
var
	opcion:char;
begin
	repeat
		clrscr;
		textcolor(14);
		gotoxy(2,1);writeln('==Menu Principal==');
		textcolor(10);
		gotoxy(2,3);writeln('1- Corte de control');
		gotoxy(2,5);writeln('2- Actualizar cajeros');
		gotoxy(2,7);writeln('3- Actualizar cuentas');
		gotoxy(2,9);writeln('4- Consulta de saldo de una cuenta');
		gotoxy(2,11);writeln('5- Alta de registro');
		gotoxy(2,13);writeln('6- Baja de registro');
		gotoxy(2,15);writeln('7- Modificacion de registro');
		textcolor(12);
		gotoxy(2,17);writeln('8- Salir');
		textcolor(45);
		gotoxy(2,19);writeln('Elija una opcion');
		repeat
			opcion:=readkey;
		until opcion in ['1'..'8'];
		clrscr;
		case opcion of
			'1':corte(movi,v,v2);
			'2':actualizar_cajeros(cajero,v);
			'3':actualizar_cuentas(cuenta,v2);
			'4':consultas(cuenta);
			'5':altas(cuenta);
			'6':bajas(cuenta);
			'7':modificaciones(cuenta);
		end;
	until opcion='8';
end;	


BEGIN																								//programa principal
	assign(movi,'D:\UNLU\Programas en Pascal 2015\Archivos para TP Obligatorio 2\movi.txt');
	assign(cuenta,'D:\UNLU\Programas en Pascal 2015\Archivos para TP Obligatorio 2\cuentas.dat');
	assign(cajero,'D:\UNLU\Programas en Pascal 2015\Archivos para TP Obligatorio 2\cajeros.dat');
	inicializar_vector(v);
	inicializar_vector2(v2);
	menu(movi,cuenta,cajero,v,v2);
END.

