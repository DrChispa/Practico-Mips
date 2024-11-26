.data
slist:	.word 0
cclist:	.word 0
wclist:	.word 0
schedv: .space 32
menu:	.ascii "Colecciones de objetos catergorizados\n"
	.ascii "=====================================\n"
	.ascii "1-Nueva Categoria\n"
	.ascii "2-Siguiente Categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objetos de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error:	.asciiz "Error: "
listarcategorias: .ascii "4-Listar categorias\n"
return: .asciiz "\n"
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat:	.asciiz "\nSe ha seleccionado la categoria: "
idObj:	.asciiz "\nIngrese el ID de un objeto: "
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "La operacion se realizo con exito\n\n"

.text
main: 	
	la $t0, schedv
	la $t1, exit
	sw $t1, 0($t0)
	la $t1, newcategory
	sw $t1, 4($t0)
	la $t1, nextcategory
	sw $t1, 8($t0)
	la $t1, prevcategory
	sw $t1, 12($t0)
	la $t1, listcategories
	sw $t1, 16($t0)
	la $t1, delcurrcategory
	sw $t1, 20($t0)
	la $t1, addnodecat
	sw $t1, 24($t0)
	la $t1, listobjects
	sw $t1, 28($t0)
	la $t1, delobj
	
	
	
loop: 
	la $a0, menu
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	sll $t0, $t0, 2
	la $t1, schedv
	add $t0, $t0, $t1
	lw $t1, 0($t0)
	jalr $t1
	j loop
	
smalloc: 
	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
	
	

sbrk:
	li $a0, 16
	li $v0, 9
	syscall
	jr $ra
	
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist
	jr $ra
	
newcategory:
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	la $a0, catName #Input category name
	jal getblock
	move $a2, $v0 # a2= *char de category name
	la $a0, cclist	# a0 = list
	li $a1, 0	# $a1 = NULL
	jal addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # actualiza la lista como si fuera nula
	
	

newcategory_end:
	li $v0, 0 #return success
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra	
	
nextcategory:
    	lw $t0, wclist       
    	beqz $t0, error_201  
    	lw $t1, 12($t0) #ubico el puntero siguiente
    	beq $t0, $t1, error_202  
    	sw $t1, wclist
    	la $a0, selCat
    	li $v0, 4
    	syscall
      	lw $a0, 8($t1)       
    	li $v0, 4            
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	jr $ra



prevcategory:
   	lw $t0, wclist       
    	beqz $t0, error_201  
    	lw $t1, 0($t0) #ubico el puntero siguiente
    	beq $t0, $t1, error_202  
    	sw $t1, wclist
    	la $a0, selCat
    	li $v0, 4
    	syscall
      	lw $a0, 8($t1)       
    	li $v0, 4            
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	jr $ra

# a0: list adress
# a1: NULL if category, node adress if object
# v0: node adress added


listcategories:

delcurrcategory:

addnodecat:

listobjects:

delobj:

addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) #setea el contenido del nodo
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) #direccion del primer nodo
	beqz $t0, addnode_empty_list
	

addnode_to_end:
	lw $t1, ($t0) #ultima direccion del nodo
	# actualiza los punteros previo y siguiente del nodo
	sw $t1, 0($t0)
	sw $t0, 12($v0)
	# actualiza previo y siguiente a un nuevo nodo
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit

addnode_empty_list:
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
	

addnode_exit:
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
	
	# a0: direccion del nodo a eliminar
	# a1: lista de direccion donde el nodo es eliminado

delnode:
	addi $sp, $sp, -8
	sw $ra 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0)
	jal sfree
	lw $a0, 4($sp)
	lw $t0, 12($a0)
	
node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0)
	sw $t1, 0($t0)
	sw $t0, 12($t1)
	lw $t1, 0($a1)
	
again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1)
	j delnode_exit

delnode_point_self:
	sw $zero, ($a1)

delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

	# a0: msg to ask
	#v0: block address allocated with string
getblock:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	li $v0, 4
	syscall
	jal smalloc
	move $a0, $v0
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
exit:
	li $v0, 10
	syscall

#Manejo de errores
error_201:
    la $a0, error
    li $v0, 4
    syscall
    li $a0, 201
    li $v0, 1
    syscall
    jr $ra

error_202:
    la $a0, error
    li $v0, 4
    syscall
    li $a0, 202
    li $v0, 1
    syscall
    jr $ra
    
error_301:
    la $a0, error
    li $v0, 4
    syscall
    li $a0, 301
    li $v0, 1
    syscall
    jr $ra
