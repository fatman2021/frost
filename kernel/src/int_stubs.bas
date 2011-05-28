#include once "inc/int_stubs.bi"
#include once "inc/cpu.bi"
#include once "inc/pic.bi"
#include once "inc/tasks.bi"
#include once "inc/video.bi"

common shared tss_ptr as uinteger ptr

function handle_interrupt cdecl (cpu as cpu_state ptr) as cpu_state ptr
    dim new_cpu as cpu_state ptr = cpu
    select case cpu->int_nr
        case 0 to &h13
            video.cout("",video.endl)
            video.cout("EXCEPTION ")
            video.cout(cpu->int_nr, video.endl)
            video.cout("",video.endl)
            video.cout("system halted.")
            asm cli
            asm hlt
        case &h20
            new_cpu = tasks.schedule(cpu)
            tss_ptr[1] = cuint(new_cpu)+sizeof(cpu_state)
        case &h62
            video.cout("The syscall-interrupt has been called.",video.endl)
        case else
    end select
    
    '// important: if the int is an irq, send the EOI
    if ((cpu->int_nr > &h1F) and (cpu->int_nr < &h30)) then
        pic.send_eoi(cpu->int_nr - &h20)
    end if
    
    return new_cpu
end function