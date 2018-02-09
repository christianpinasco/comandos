// UNIFORMADOS // 

class Uniformado{
	var denuncias
	var tiempoExp
	var conflictos
	var categoria
	
	constructor(_denuncias, _tiempoExp, _conflictos, _categoria) {
		denuncias = _denuncias
		tiempoExp = _tiempoExp
		conflictos = _conflictos
		categoria = _categoria
	}
	
	method puedeIntegrarGrupoComando(){
		return self.esExperimentado() && self.denunciasMenorA(5)
	}
	method denunciasMenorA(num){
		return denuncias < num
	}
	method esExperimentado(){
		return null
	}
	method recibirDenuncia(){
		categoria.recibirDenuncia(self)
	}
	method adquirirExp(cant){
		tiempoExp += cant
	}
	method recibirEscarmiento(){
		self.recibirDenuncia()
	}
	method prevenirUsurpacion(cant){
		self.adquirirExp(cant)
	}
	method conflictos(){
		return conflictos
	}
	method sumarConflicto(){
		conflictos += 1
	}
	method categoria(){
		return categoria
	}
	method categoria(nuevaCategoria){
		categoria = nuevaCategoria
	}
	method incrementarDenunciasEn(num){
		denuncias += num
	}
}

class Escorpiones inherits Uniformado{
	var horasEntrenamiento
	constructor(_denuncias, _tiempoExp, _conflictos, _horasEntrenamiento) = super(_denuncias, _tiempoExp, _conflictos, _categoria) {
		horasEntrenamiento = _horasEntrenamiento
	}
	
	override method esExperimentado(){
		return horasEntrenamiento > 200
	}
	method entrenar(cant){
		horasEntrenamiento += 10*cant
	}
	method aumentarHorasEntrenamiento(cant){
		horasEntrenamiento += cant
	}
	override method recibirEscarmiento(){
		super()
		self.entrenar(2)
	}
	override method prevenirUsurpacion(cant){
		super(cant)
		self.aumentarHorasEntrenamiento(cant+1)
	}
}

class Gaviotas inherits Uniformado{
	var habilidades
	constructor(_denuncias, _tiempoExp, _conflictos, _habilidades) = super(_denuncias, _tiempoExp, _conflictos, _categoria) {
		habilidades = _habilidades
	}
	
	override method esExperimentado(){
		return habilidades.contains("disuasion")
	}
	override method prevenirUsurpacion(cant){
		super(cant)
		if(cant>5){
			habilidades.add("desalojo")
		}
	}
}

class UserException inherits Exception { }

// GRUPO COMANDO // 

class GrupoComando{
	var integrantes
	constructor(_integrantes) {
		integrantes = _integrantes
	}
	
	method actuarSobre(conflicto){
		if(conflicto.tieneSolucion(self)){
		conflicto.ejectutar(self)	
		}
		else throw new UserException ("No se puede resolver conflicto")
	}
	method integrantes(){
		return integrantes.size()
	}
	method recibirEscarmientoGrupal(){
		integrantes.map({unIntegrante => unIntegrante.recibirEscarmiento()})
	}
	method prevenirUsurpacionGrupal(cant){
		integrantes.map({unIntegrante => unIntegrante.prevenirUsurpacion(cant)})
		
	}
	method sumarConflictoGrupal(){
		integrantes.map({unIntegrante => unIntegrante.sumarConflicto()})
	}
}

// CONFLICTOS //

class Conflicto{
	method ejecutar(grupo){
		grupo.sumarConflictoGrupal()
	}
}

class CorteDeRuta inherits Conflicto{
	var manifestantes
	constructor (_manifestantes) {
		manifestantes = _manifestantes
	}
	
	method tieneSolucion(grupo){
		return manifestantes < grupo.integrantes()
	}
	override method ejecutar(grupo){
		super(grupo)
		manifestantes = manifestantes/2
		grupo.recibirEscarmiento()
		
	}
}

class Lugar inherits Conflicto{
	var hectareasLugar
	var obejas
	constructor(_hectareasLugar, _obejas) {
		hectareasLugar = _hectareasLugar obejas= _obejas
	}
	
	method esAmplio(){
		return hectareasLugar >20000
	}
	method disminuirObejasEn(porcentaje){
		obejas -= obejas*(porcentaje/100)
	}
	override method ejecutar(grupo){
		super(grupo)
		self.disminuirObejasEn(20)
		grupo.prevenirUsurpacionGrupal(self.tiempoExp())
	}
	method tiempoExp(){
		return hectareasLugar / 100
	}
	method tieneSolucion(grupo){
		return self.esAmplio()
	}
}


class UsurpacionDeLugares inherits Lugar{
	constructor(_hectareasLugar, _obejas) = super(_hectareasLugar, _obejas)
}

class UsurpacionPrivada inherits Lugar{
	var duenio
	constructor(_hectareasLugar, _obejas, _duenio) = super(_hectareasLugar, _obejas) {
		duenio = _duenio
	}
	
	override method tieneSolucion(grupo) {
		return duenio.esAcaudalado() || super(grupo)
	}
	override method ejecutar(grupo){
		super(grupo)
		grupo.recibirEscarmientoGrupal()
		
		
	}
}

class Duenio {
	var fortuna
	constructor(_fortuna) {
		fortuna = _fortuna
	}
	
	method esAcaudalado(){
		return fortuna > 1000000
	}
}

// ACADEMIA // 

object academia{
	var teniente
	
	method teniente(_teniente) {
		teniente = _teniente
	}
	method esCategoria(categoria, uniformado){
		return categoria.laMerece(uniformado)
	}
	method asignarCategoria(categoria, uniformado){
		if(self.esCategoria(categoria, uniformado)){
			uniformado.categoria(categoria)
		}else throw new UserException ("No merece la categoria")
	}
	method recibirDenuncia(){
		teniente.recibirDenuncia()
	}
}

// CATEGORIAS //

class Pichon{
	method laMerece(uniformado){
		return true
	}
	method recibirDenuncia(uniformado){
		academia.recibirDenuncia()
	}
}

class Adulto inherits Pichon{
	override method laMerece(uniformado){
		super(uniformado)
		return uniformado.conflictos() > 10
	}
	override method recibirDenuncia(uniformado){
		uniformado.incrementarDenunciasEn(1)
	}
}

class Intergalactico inherits Adulto{
	override method laMerece(uniformado){
		super(uniformado)
		return uniformado.esExperimentado()
	}
	override method recibirDenuncia(uniformado){
		uniformado.incrementarDenunciasEn(3)
	}
}

class ChuckNorris inherits Intergalactico{
	override method laMerece(uniformado){
	super(uniformado)
	return uniformado.conflictos() > 500
	}
	override method recibirDenuncia(uniformado){
		
	}	
}