using CEnum

# CUBLAS uses CUDA runtime objects, which are compatible with our driver usage
const cudaStream_t = CUstream

# outlined functionality to avoid GC frame allocation
@noinline function throw_api_error(res)
    if res == CUBLAS_STATUS_ALLOC_FAILED
        throw(OutOfGPUMemoryError())
    else
        throw(CUBLASError(res))
    end
end

macro check(ex, errs...)
    check = :(isequal(err, CUBLAS_STATUS_ALLOC_FAILED))
    for err in errs
        check = :($check || isequal(err, $(esc(err))))
    end

    quote
        res = @retry_reclaim err -> $check $(esc(ex))
        if res != CUBLAS_STATUS_SUCCESS
            throw_api_error(res)
        end

        nothing
    end
end

mutable struct cublasContext end

const cublasHandle_t = Ptr{cublasContext}

@cenum cublasStatus_t::UInt32 begin
    CUBLAS_STATUS_SUCCESS = 0
    CUBLAS_STATUS_NOT_INITIALIZED = 1
    CUBLAS_STATUS_ALLOC_FAILED = 3
    CUBLAS_STATUS_INVALID_VALUE = 7
    CUBLAS_STATUS_ARCH_MISMATCH = 8
    CUBLAS_STATUS_MAPPING_ERROR = 11
    CUBLAS_STATUS_EXECUTION_FAILED = 13
    CUBLAS_STATUS_INTERNAL_ERROR = 14
    CUBLAS_STATUS_NOT_SUPPORTED = 15
    CUBLAS_STATUS_LICENSE_ERROR = 16
end

@checked function cublasCreate_v2(handle)
    initialize_context()
    @ccall libcublas.cublasCreate_v2(handle::Ref{cublasHandle_t})::cublasStatus_t
end

@checked function cublasDestroy_v2(handle)
    initialize_context()
    @ccall libcublas.cublasDestroy_v2(handle::cublasHandle_t)::cublasStatus_t
end

@checked function cublasGetVersion_v2(handle, version)
    @ccall libcublas.cublasGetVersion_v2(handle::cublasHandle_t,
                                         version::Ref{Cint})::cublasStatus_t
end

@checked function cublasSetWorkspace_v2(handle, workspace, workspaceSizeInBytes)
    initialize_context()
    @ccall libcublas.cublasSetWorkspace_v2(handle::cublasHandle_t, workspace::CuPtr{Cvoid},
                                           workspaceSizeInBytes::Csize_t)::cublasStatus_t
end

@checked function cublasSetStream_v2(handle, streamId)
    initialize_context()
    @ccall libcublas.cublasSetStream_v2(handle::cublasHandle_t,
                                        streamId::cudaStream_t)::cublasStatus_t
end

@checked function cublasGetStream_v2(handle, streamId)
    initialize_context()
    @ccall libcublas.cublasGetStream_v2(handle::cublasHandle_t,
                                        streamId::Ref{CUstream})::cublasStatus_t
end

@cenum cublasPointerMode_t::UInt32 begin
    CUBLAS_POINTER_MODE_HOST = 0
    CUBLAS_POINTER_MODE_DEVICE = 1
end

@checked function cublasGetPointerMode_v2(handle, mode)
    initialize_context()
    @ccall libcublas.cublasGetPointerMode_v2(handle::cublasHandle_t,
                                             mode::Ref{cublasPointerMode_t})::cublasStatus_t
end

@checked function cublasSetPointerMode_v2(handle, mode)
    initialize_context()
    @ccall libcublas.cublasSetPointerMode_v2(handle::cublasHandle_t,
                                             mode::cublasPointerMode_t)::cublasStatus_t
end

@checked function cublasSnrm2_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasSnrm2_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDnrm2_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDnrm2_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasScnrm2_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasScnrm2_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                     incx::Cint, result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDznrm2_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDznrm2_v2(handle::cublasHandle_t, n::Cint,
                                     x::CuPtr{cuDoubleComplex}, incx::Cint,
                                     result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSdot_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasSdot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                   incx::Cint, y::CuPtr{Cfloat}, incy::Cint,
                                   result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDdot_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasDdot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                   incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                   result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasCdotu_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasCdotu_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    result::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasCdotc_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasCdotc_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    result::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasZdotu_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasZdotu_v2(handle::cublasHandle_t, n::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    result::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasZdotc_v2(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasZdotc_v2(handle::cublasHandle_t, n::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    result::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasSscal_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasDscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasDscal_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasCscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasCscal_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasCsscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasCsscal_v2(handle::cublasHandle_t, n::Cint,
                                     alpha::RefOrCuRef{Cfloat}, x::CuPtr{cuComplex},
                                     incx::Cint)::cublasStatus_t
end

@checked function cublasZscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasZscal_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasZdscal_v2(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasZdscal_v2(handle::cublasHandle_t, n::Cint,
                                     alpha::RefOrCuRef{Cdouble}, x::CuPtr{cuDoubleComplex},
                                     incx::Cint)::cublasStatus_t
end

@checked function cublasSaxpy_v2(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasSaxpy_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                    y::CuPtr{Cfloat}, incy::Cint)::cublasStatus_t
end

@checked function cublasDaxpy_v2(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDaxpy_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasCaxpy_v2(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCaxpy_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZaxpy_v2(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZaxpy_v2(handle::cublasHandle_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasScopy_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasScopy_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, y::CuPtr{Cfloat},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasDcopy_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDcopy_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasCcopy_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCcopy_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZcopy_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZcopy_v2(handle::cublasHandle_t, n::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasSswap_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasSswap_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, y::CuPtr{Cfloat},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasDswap_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDswap_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasCswap_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCswap_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZswap_v2(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZswap_v2(handle::cublasHandle_t, n::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasIsamax_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIsamax_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIdamax_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIdamax_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIcamax_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIcamax_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIzamax_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIzamax_v2(handle::cublasHandle_t, n::Cint,
                                     x::CuPtr{cuDoubleComplex}, incx::Cint,
                                     result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIsamin_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIsamin_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIdamin_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIdamin_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIcamin_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIcamin_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                     incx::Cint, result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIzamin_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIzamin_v2(handle::cublasHandle_t, n::Cint,
                                     x::CuPtr{cuDoubleComplex}, incx::Cint,
                                     result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasSasum_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasSasum_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDasum_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDasum_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasScasum_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasScasum_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                     incx::Cint, result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDzasum_v2(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDzasum_v2(handle::cublasHandle_t, n::Cint,
                                     x::CuPtr{cuDoubleComplex}, incx::Cint,
                                     result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasSrot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                   incx::Cint, y::CuPtr{Cfloat}, incy::Cint,
                                   c::RefOrCuRef{Cfloat},
                                   s::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasDrot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                   incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                   c::RefOrCuRef{Cdouble},
                                   s::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasCrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasCrot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                   incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                   c::RefOrCuRef{Cfloat},
                                   s::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasCsrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasCsrot_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    c::RefOrCuRef{Cfloat},
                                    s::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasZrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasZrot_v2(handle::cublasHandle_t, n::Cint,
                                   x::CuPtr{cuDoubleComplex}, incx::Cint,
                                   y::CuPtr{cuDoubleComplex}, incy::Cint,
                                   c::RefOrCuRef{Cdouble},
                                   s::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasZdrot_v2(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasZdrot_v2(handle::cublasHandle_t, n::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    c::RefOrCuRef{Cdouble},
                                    s::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSrotg_v2(handle, a, b, c, s)
    initialize_context()
    @ccall libcublas.cublasSrotg_v2(handle::cublasHandle_t, a::RefOrCuRef{Cfloat},
                                    b::RefOrCuRef{Cfloat}, c::RefOrCuRef{Cfloat},
                                    s::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDrotg_v2(handle, a, b, c, s)
    initialize_context()
    @ccall libcublas.cublasDrotg_v2(handle::cublasHandle_t, a::RefOrCuRef{Cdouble},
                                    b::RefOrCuRef{Cdouble}, c::PtrOrCuPtr{Cdouble},
                                    s::PtrOrCuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasCrotg_v2(handle, a, b, c, s)
    initialize_context()
    @ccall libcublas.cublasCrotg_v2(handle::cublasHandle_t, a::RefOrCuRef{cuComplex},
                                    b::RefOrCuRef{cuComplex}, c::RefOrCuRef{Cfloat},
                                    s::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasZrotg_v2(handle, a, b, c, s)
    initialize_context()
    @ccall libcublas.cublasZrotg_v2(handle::cublasHandle_t, a::RefOrCuRef{cuDoubleComplex},
                                    b::RefOrCuRef{cuDoubleComplex}, c::RefOrCuRef{Cdouble},
                                    s::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSrotm_v2(handle, n, x, incx, y, incy, param)
    initialize_context()
    @ccall libcublas.cublasSrotm_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, y::CuPtr{Cfloat}, incy::Cint,
                                    param::PtrOrCuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDrotm_v2(handle, n, x, incx, y, incy, param)
    initialize_context()
    @ccall libcublas.cublasDrotm_v2(handle::cublasHandle_t, n::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                    param::PtrOrCuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasSrotmg_v2(handle, d1, d2, x1, y1, param)
    initialize_context()
    @ccall libcublas.cublasSrotmg_v2(handle::cublasHandle_t, d1::RefOrCuRef{Cfloat},
                                     d2::RefOrCuRef{Cfloat}, x1::RefOrCuRef{Cfloat},
                                     y1::RefOrCuRef{Cfloat},
                                     param::PtrOrCuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDrotmg_v2(handle, d1, d2, x1, y1, param)
    initialize_context()
    @ccall libcublas.cublasDrotmg_v2(handle::cublasHandle_t, d1::RefOrCuRef{Cdouble},
                                     d2::RefOrCuRef{Cdouble}, x1::RefOrCuRef{Cdouble},
                                     y1::RefOrCuRef{Cdouble},
                                     param::PtrOrCuPtr{Cdouble})::cublasStatus_t
end

@cenum cublasOperation_t::UInt32 begin
    CUBLAS_OP_N = 0
    CUBLAS_OP_T = 1
    CUBLAS_OP_C = 2
    CUBLAS_OP_HERMITAN = 2
    CUBLAS_OP_CONJG = 3
end

@checked function cublasSgemv_v2(handle, trans, m, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSgemv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, alpha::RefOrCuRef{Cfloat},
                                    A::CuPtr{Cfloat}, lda::Cint, x::CuPtr{Cfloat},
                                    incx::Cint, beta::RefOrCuRef{Cfloat}, y::CuPtr{Cfloat},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasDgemv_v2(handle, trans, m, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDgemv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, alpha::RefOrCuRef{Cdouble},
                                    A::CuPtr{Cdouble}, lda::Cint, x::CuPtr{Cdouble},
                                    incx::Cint, beta::RefOrCuRef{Cdouble},
                                    y::CuPtr{Cdouble}, incy::Cint)::cublasStatus_t
end

@checked function cublasCgemv_v2(handle, trans, m, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasCgemv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, alpha::RefOrCuRef{cuComplex},
                                    A::CuPtr{cuComplex}, lda::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, beta::RefOrCuRef{cuComplex},
                                    y::CuPtr{cuComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasZgemv_v2(handle, trans, m, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZgemv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasSgbmv_v2(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx, beta,
                                 y, incy)
    initialize_context()
    @ccall libcublas.cublasSgbmv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, kl::Cint, ku::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    x::CuPtr{Cfloat}, incx::Cint, beta::RefOrCuRef{Cfloat},
                                    y::CuPtr{Cfloat}, incy::Cint)::cublasStatus_t
end

@checked function cublasDgbmv_v2(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx, beta,
                                 y, incy)
    initialize_context()
    @ccall libcublas.cublasDgbmv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, kl::Cint, ku::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, x::CuPtr{Cdouble}, incx::Cint,
                                    beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasCgbmv_v2(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx, beta,
                                 y, incy)
    initialize_context()
    @ccall libcublas.cublasCgbmv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, kl::Cint, ku::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, x::CuPtr{cuComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuComplex}, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZgbmv_v2(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx, beta,
                                 y, incy)
    initialize_context()
    @ccall libcublas.cublasZgbmv_v2(handle::cublasHandle_t, trans::cublasOperation_t,
                                    m::Cint, n::Cint, kl::Cint, ku::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@cenum cublasFillMode_t::UInt32 begin
    CUBLAS_FILL_MODE_LOWER = 0
    CUBLAS_FILL_MODE_UPPER = 1
    CUBLAS_FILL_MODE_FULL = 2
end

@cenum cublasDiagType_t::UInt32 begin
    CUBLAS_DIAG_NON_UNIT = 0
    CUBLAS_DIAG_UNIT = 1
end

@checked function cublasStrmv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStrmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{Cfloat}, lda::Cint, x::CuPtr{Cfloat},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasDtrmv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtrmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{Cdouble}, lda::Cint,
                                    x::CuPtr{Cdouble}, incx::Cint)::cublasStatus_t
end

@checked function cublasCtrmv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtrmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{cuComplex}, lda::Cint,
                                    x::CuPtr{cuComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasZtrmv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtrmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasStbmv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{Cfloat}, lda::Cint,
                                    x::CuPtr{Cfloat}, incx::Cint)::cublasStatus_t
end

@checked function cublasDtbmv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{Cdouble}, lda::Cint,
                                    x::CuPtr{Cdouble}, incx::Cint)::cublasStatus_t
end

@checked function cublasCtbmv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{cuComplex}, lda::Cint,
                                    x::CuPtr{cuComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasZtbmv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasStpmv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasStpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{Cfloat}, x::CuPtr{Cfloat},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasDtpmv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasCtpmv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasZtpmv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasStrsv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStrsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{Cfloat}, lda::Cint, x::CuPtr{Cfloat},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasDtrsv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtrsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{Cdouble}, lda::Cint,
                                    x::CuPtr{Cdouble}, incx::Cint)::cublasStatus_t
end

@checked function cublasCtrsv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtrsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{cuComplex}, lda::Cint,
                                    x::CuPtr{cuComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasZtrsv_v2(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtrsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasStpsv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasStpsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{Cfloat}, x::CuPtr{Cfloat},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasDtpsv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtpsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasCtpsv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtpsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint)::cublasStatus_t
end

@checked function cublasZtpsv_v2(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtpsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, AP::CuPtr{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasStbsv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStbsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{Cfloat}, lda::Cint,
                                    x::CuPtr{Cfloat}, incx::Cint)::cublasStatus_t
end

@checked function cublasDtbsv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtbsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{Cdouble}, lda::Cint,
                                    x::CuPtr{Cdouble}, incx::Cint)::cublasStatus_t
end

@checked function cublasCtbsv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtbsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{cuComplex}, lda::Cint,
                                    x::CuPtr{cuComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasZtbsv_v2(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtbsv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, diag::cublasDiagType_t,
                                    n::Cint, k::Cint, A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint)::cublasStatus_t
end

@checked function cublasSsymv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSsymv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    x::CuPtr{Cfloat}, incx::Cint, beta::RefOrCuRef{Cfloat},
                                    y::CuPtr{Cfloat}, incy::Cint)::cublasStatus_t
end

@checked function cublasDsymv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDsymv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, x::CuPtr{Cdouble}, incx::Cint,
                                    beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasCsymv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasCsymv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, x::CuPtr{cuComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuComplex}, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZsymv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZsymv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasChemv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasChemv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, x::CuPtr{cuComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuComplex}, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZhemv_v2(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZhemv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasSsbmv_v2(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSsbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    k::Cint, alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                    lda::Cint, x::CuPtr{Cfloat}, incx::Cint,
                                    beta::RefOrCuRef{Cfloat}, y::CuPtr{Cfloat},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasDsbmv_v2(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDsbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    k::Cint, alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, x::CuPtr{Cdouble}, incx::Cint,
                                    beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasChbmv_v2(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasChbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    k::Cint, alpha::RefOrCuRef{cuComplex},
                                    A::CuPtr{cuComplex}, lda::Cint, x::CuPtr{cuComplex},
                                    incx::Cint, beta::RefOrCuRef{cuComplex},
                                    y::CuPtr{cuComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasZhbmv_v2(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZhbmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    k::Cint, alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasSspmv_v2(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSspmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, AP::CuPtr{Cfloat},
                                    x::CuPtr{Cfloat}, incx::Cint, beta::RefOrCuRef{Cfloat},
                                    y::CuPtr{Cfloat}, incy::Cint)::cublasStatus_t
end

@checked function cublasDspmv_v2(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDspmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, AP::CuPtr{Cdouble},
                                    x::CuPtr{Cdouble}, incx::Cint,
                                    beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasChpmv_v2(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasChpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, AP::CuPtr{cuComplex},
                                    x::CuPtr{cuComplex}, incx::Cint,
                                    beta::RefOrCuRef{cuComplex}, y::CuPtr{cuComplex},
                                    incy::Cint)::cublasStatus_t
end

@checked function cublasZhpmv_v2(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZhpmv_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    AP::CuPtr{cuDoubleComplex}, x::CuPtr{cuDoubleComplex},
                                    incx::Cint, beta::RefOrCuRef{cuDoubleComplex},
                                    y::CuPtr{cuDoubleComplex}, incy::Cint)::cublasStatus_t
end

@checked function cublasSger_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasSger_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                   alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                   y::CuPtr{Cfloat}, incy::Cint, A::CuPtr{Cfloat},
                                   lda::Cint)::cublasStatus_t
end

@checked function cublasDger_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasDger_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                   alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                   incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                   A::CuPtr{Cdouble}, lda::Cint)::cublasStatus_t
end

@checked function cublasCgeru_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCgeru_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    A::CuPtr{cuComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasCgerc_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCgerc_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    A::CuPtr{cuComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasZgeru_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZgeru_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    A::CuPtr{cuDoubleComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasZgerc_v2(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZgerc_v2(handle::cublasHandle_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    A::CuPtr{cuDoubleComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasSsyr_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasSsyr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                   A::CuPtr{Cfloat}, lda::Cint)::cublasStatus_t
end

@checked function cublasDsyr_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasDsyr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                   incx::Cint, A::CuPtr{Cdouble}, lda::Cint)::cublasStatus_t
end

@checked function cublasCsyr_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasCsyr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                   incx::Cint, A::CuPtr{cuComplex},
                                   lda::Cint)::cublasStatus_t
end

@checked function cublasZsyr_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasZsyr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   x::CuPtr{cuDoubleComplex}, incx::Cint,
                                   A::CuPtr{cuDoubleComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasCher_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasCher_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cfloat}, x::CuPtr{cuComplex},
                                   incx::Cint, A::CuPtr{cuComplex},
                                   lda::Cint)::cublasStatus_t
end

@checked function cublasZher_v2(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasZher_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cdouble}, x::CuPtr{cuDoubleComplex},
                                   incx::Cint, A::CuPtr{cuDoubleComplex},
                                   lda::Cint)::cublasStatus_t
end

@checked function cublasSspr_v2(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasSspr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                   AP::CuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDspr_v2(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasDspr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                   incx::Cint, AP::CuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasChpr_v2(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasChpr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cfloat}, x::CuPtr{cuComplex},
                                   incx::Cint, AP::CuPtr{cuComplex})::cublasStatus_t
end

@checked function cublasZhpr_v2(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasZhpr_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                   alpha::RefOrCuRef{Cdouble}, x::CuPtr{cuDoubleComplex},
                                   incx::Cint, AP::CuPtr{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSsyr2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasSsyr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                    y::CuPtr{Cfloat}, incy::Cint, A::CuPtr{Cfloat},
                                    lda::Cint)::cublasStatus_t
end

@checked function cublasDsyr2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasDsyr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                    A::CuPtr{Cdouble}, lda::Cint)::cublasStatus_t
end

@checked function cublasCsyr2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCsyr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    A::CuPtr{cuComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasZsyr2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZsyr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    A::CuPtr{cuDoubleComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasCher2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCher2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    A::CuPtr{cuComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasZher2_v2(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZher2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    A::CuPtr{cuDoubleComplex}, lda::Cint)::cublasStatus_t
end

@checked function cublasSspr2_v2(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasSspr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat}, incx::Cint,
                                    y::CuPtr{Cfloat}, incy::Cint,
                                    AP::CuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDspr2_v2(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasDspr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                    incx::Cint, y::CuPtr{Cdouble}, incy::Cint,
                                    AP::CuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasChpr2_v2(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasChpr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                    incx::Cint, y::CuPtr{cuComplex}, incy::Cint,
                                    AP::CuPtr{cuComplex})::cublasStatus_t
end

@checked function cublasZhpr2_v2(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasZhpr2_v2(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    x::CuPtr{cuDoubleComplex}, incx::Cint,
                                    y::CuPtr{cuDoubleComplex}, incy::Cint,
                                    AP::CuPtr{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSgemm_v2(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                 beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSgemm_v2(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    B::CuPtr{Cfloat}, ldb::Cint, beta::RefOrCuRef{Cfloat},
                                    C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDgemm_v2(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                 beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDgemm_v2(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, B::CuPtr{Cdouble}, ldb::Cint,
                                    beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasCgemm_v2(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                 beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm_v2(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasZgemm_v2(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                 beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZgemm_v2(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSsyrk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSsyrk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    beta::RefOrCuRef{Cfloat}, C::CuPtr{Cfloat},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasDsyrk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDsyrk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasCsyrk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, beta::RefOrCuRef{cuComplex},
                                    C::CuPtr{cuComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZsyrk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZsyrk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasCherk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCherk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{cuComplex},
                                    lda::Cint, beta::RefOrCuRef{Cfloat},
                                    C::CuPtr{cuComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZherk_v2(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZherk_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Cint, k::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{cuDoubleComplex},
                                    lda::Cint, beta::RefOrCuRef{Cdouble},
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSsyr2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasSsyr2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                     B::CuPtr{Cfloat}, ldb::Cint, beta::RefOrCuRef{Cfloat},
                                     C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDsyr2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasDsyr2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                     lda::Cint, B::CuPtr{Cdouble}, ldb::Cint,
                                     beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                     ldc::Cint)::cublasStatus_t
end

@checked function cublasCsyr2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasCsyr2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                     lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                     beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                     ldc::Cint)::cublasStatus_t
end

@checked function cublasZsyr2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasZsyr2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuDoubleComplex},
                                     A::CuPtr{cuDoubleComplex}, lda::Cint,
                                     B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                     beta::RefOrCuRef{cuDoubleComplex},
                                     C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasCher2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasCher2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                     lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                     beta::RefOrCuRef{Cfloat}, C::CuPtr{cuComplex},
                                     ldc::Cint)::cublasStatus_t
end

@checked function cublasZher2k_v2(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasZher2k_v2(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuDoubleComplex},
                                     A::CuPtr{cuDoubleComplex}, lda::Cint,
                                     B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                     beta::RefOrCuRef{Cdouble}, C::CuPtr{cuDoubleComplex},
                                     ldc::Cint)::cublasStatus_t
end

@cenum cublasSideMode_t::UInt32 begin
    CUBLAS_SIDE_LEFT = 0
    CUBLAS_SIDE_RIGHT = 1
end

@checked function cublasSsymm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasSsymm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    B::CuPtr{Cfloat}, ldb::Cint, beta::RefOrCuRef{Cfloat},
                                    C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDsymm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasDsymm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, B::CuPtr{Cdouble}, ldb::Cint,
                                    beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasCsymm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasCsymm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasZsymm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasZsymm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasChemm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasChemm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasZhemm_v2(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasZhemm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasStrsm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb)
    initialize_context()
    @ccall libcublas.cublasStrsm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    B::CuPtr{Cfloat}, ldb::Cint)::cublasStatus_t
end

@checked function cublasDtrsm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb)
    initialize_context()
    @ccall libcublas.cublasDtrsm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, B::CuPtr{Cdouble}, ldb::Cint)::cublasStatus_t
end

@checked function cublasCtrsm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb)
    initialize_context()
    @ccall libcublas.cublasCtrsm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, B::CuPtr{cuComplex},
                                    ldb::Cint)::cublasStatus_t
end

@checked function cublasZtrsm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb)
    initialize_context()
    @ccall libcublas.cublasZtrsm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    B::CuPtr{cuDoubleComplex}, ldb::Cint)::cublasStatus_t
end

@checked function cublasStrmm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasStrmm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                    B::CuPtr{Cfloat}, ldb::Cint, C::CuPtr{Cfloat},
                                    ldc::Cint)::cublasStatus_t
end

@checked function cublasDtrmm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDtrmm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Cint, B::CuPtr{Cdouble}, ldb::Cint,
                                    C::CuPtr{Cdouble}, ldc::Cint)::cublasStatus_t
end

@checked function cublasCtrmm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCtrmm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                    C::CuPtr{cuComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZtrmm_v2(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                 ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZtrmm_v2(handle::cublasHandle_t, side::cublasSideMode_t,
                                    uplo::cublasFillMode_t, trans::cublasOperation_t,
                                    diag::cublasDiagType_t, m::Cint, n::Cint,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Cint,
                                    B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                    C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSnrm2_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasSnrm2_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                       incx::Int64,
                                       result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDnrm2_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDnrm2_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                       incx::Int64,
                                       result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasScnrm2_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasScnrm2_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuComplex}, incx::Int64,
                                        result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDznrm2_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDznrm2_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuDoubleComplex}, incx::Int64,
                                        result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSdot_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasSdot_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                      incx::Int64, y::CuPtr{Cfloat}, incy::Int64,
                                      result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDdot_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasDdot_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                      incx::Int64, y::CuPtr{Cdouble}, incy::Int64,
                                      result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasCdotu_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasCdotu_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       result::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasCdotc_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasCdotc_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       result::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasZdotu_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasZdotu_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       result::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasZdotc_v2_64(handle, n, x, incx, y, incy, result)
    initialize_context()
    @ccall libcublas.cublasZdotc_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       result::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasSscal_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasDscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasDscal_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasCscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasCscal_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasCsscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasCsscal_v2_64(handle::cublasHandle_t, n::Int64,
                                        alpha::RefOrCuRef{Cfloat}, x::CuPtr{cuComplex},
                                        incx::Int64)::cublasStatus_t
end

@checked function cublasZscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasZscal_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasZdscal_v2_64(handle, n, alpha, x, incx)
    initialize_context()
    @ccall libcublas.cublasZdscal_v2_64(handle::cublasHandle_t, n::Int64,
                                        alpha::RefOrCuRef{Cdouble},
                                        x::CuPtr{cuDoubleComplex},
                                        incx::Int64)::cublasStatus_t
end

@checked function cublasSaxpy_v2_64(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasSaxpy_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                       incx::Int64, y::CuPtr{Cfloat},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasDaxpy_v2_64(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDaxpy_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                       incx::Int64, y::CuPtr{Cdouble},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasCaxpy_v2_64(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCaxpy_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64, y::CuPtr{cuComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasZaxpy_v2_64(handle, n, alpha, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZaxpy_v2_64(handle::cublasHandle_t, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasScopy_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasScopy_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, y::CuPtr{Cfloat},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasDcopy_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDcopy_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, y::CuPtr{Cdouble},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasCcopy_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCcopy_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZcopy_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZcopy_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasSswap_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasSswap_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, y::CuPtr{Cfloat},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasDswap_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasDswap_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, y::CuPtr{Cdouble},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasCswap_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasCswap_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZswap_v2_64(handle, n, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasZswap_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasIsamax_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIsamax_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                        incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIdamax_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIdamax_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                        incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIcamax_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIcamax_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuComplex}, incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIzamax_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIzamax_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuDoubleComplex}, incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIsamin_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIsamin_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                        incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIdamin_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIdamin_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                        incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIcamin_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIcamin_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuComplex}, incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIzamin_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasIzamin_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuDoubleComplex}, incx::Int64,
                                        result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasSasum_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasSasum_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                       incx::Int64,
                                       result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDasum_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDasum_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                       incx::Int64,
                                       result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasScasum_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasScasum_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuComplex}, incx::Int64,
                                        result::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDzasum_v2_64(handle, n, x, incx, result)
    initialize_context()
    @ccall libcublas.cublasDzasum_v2_64(handle::cublasHandle_t, n::Int64,
                                        x::CuPtr{cuDoubleComplex}, incx::Int64,
                                        result::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasSrot_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                      incx::Int64, y::CuPtr{Cfloat}, incy::Int64,
                                      c::RefOrCuRef{Cfloat},
                                      s::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasDrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasDrot_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                      incx::Int64, y::CuPtr{Cdouble}, incy::Int64,
                                      c::RefOrCuRef{Cdouble},
                                      s::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasCrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasCrot_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{cuComplex},
                                      incx::Int64, y::CuPtr{cuComplex}, incy::Int64,
                                      c::RefOrCuRef{Cfloat},
                                      s::RefOrCuRef{cuComplex})::cublasStatus_t
end

@checked function cublasCsrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasCsrot_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       c::RefOrCuRef{Cfloat},
                                       s::RefOrCuRef{Cfloat})::cublasStatus_t
end

@checked function cublasZrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasZrot_v2_64(handle::cublasHandle_t, n::Int64,
                                      x::CuPtr{cuDoubleComplex}, incx::Int64,
                                      y::CuPtr{cuDoubleComplex}, incy::Int64,
                                      c::RefOrCuRef{Cdouble},
                                      s::RefOrCuRef{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasZdrot_v2_64(handle, n, x, incx, y, incy, c, s)
    initialize_context()
    @ccall libcublas.cublasZdrot_v2_64(handle::cublasHandle_t, n::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       c::RefOrCuRef{Cdouble},
                                       s::RefOrCuRef{Cdouble})::cublasStatus_t
end

@checked function cublasSrotm_v2_64(handle, n, x, incx, y, incy, param)
    initialize_context()
    @ccall libcublas.cublasSrotm_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, y::CuPtr{Cfloat}, incy::Int64,
                                       param::PtrOrCuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDrotm_v2_64(handle, n, x, incx, y, incy, param)
    initialize_context()
    @ccall libcublas.cublasDrotm_v2_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, y::CuPtr{Cdouble}, incy::Int64,
                                       param::PtrOrCuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasSgemv_v2_64(handle, trans, m, n, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasSgemv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, alpha::RefOrCuRef{Cfloat},
                                       A::CuPtr{Cfloat}, lda::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, beta::RefOrCuRef{Cfloat},
                                       y::CuPtr{Cfloat}, incy::Int64)::cublasStatus_t
end

@checked function cublasDgemv_v2_64(handle, trans, m, n, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasDgemv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, alpha::RefOrCuRef{Cdouble},
                                       A::CuPtr{Cdouble}, lda::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, beta::RefOrCuRef{Cdouble},
                                       y::CuPtr{Cdouble}, incy::Int64)::cublasStatus_t
end

@checked function cublasCgemv_v2_64(handle, trans, m, n, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasCgemv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, alpha::RefOrCuRef{cuComplex},
                                       A::CuPtr{cuComplex}, lda::Int64, x::CuPtr{cuComplex},
                                       incx::Int64, beta::RefOrCuRef{cuComplex},
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZgemv_v2_64(handle, trans, m, n, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasZgemv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasSgbmv_v2_64(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx,
                                    beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSgbmv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, kl::Int64, ku::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                       lda::Int64, x::CuPtr{Cfloat}, incx::Int64,
                                       beta::RefOrCuRef{Cfloat}, y::CuPtr{Cfloat},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasDgbmv_v2_64(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx,
                                    beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDgbmv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, kl::Int64, ku::Int64,
                                       alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                       lda::Int64, x::CuPtr{Cdouble}, incx::Int64,
                                       beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasCgbmv_v2_64(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx,
                                    beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasCgbmv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, kl::Int64, ku::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, x::CuPtr{cuComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuComplex}, y::CuPtr{cuComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasZgbmv_v2_64(handle, trans, m, n, kl, ku, alpha, A, lda, x, incx,
                                    beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZgbmv_v2_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                       m::Int64, n::Int64, kl::Int64, ku::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasStrmv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStrmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{Cfloat}, lda::Int64,
                                       x::CuPtr{Cfloat}, incx::Int64)::cublasStatus_t
end

@checked function cublasDtrmv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtrmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{Cdouble}, lda::Int64,
                                       x::CuPtr{Cdouble}, incx::Int64)::cublasStatus_t
end

@checked function cublasCtrmv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtrmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{cuComplex}, lda::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64)::cublasStatus_t
end

@checked function cublasZtrmv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtrmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasStbmv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{Cfloat}, lda::Int64,
                                       x::CuPtr{Cfloat}, incx::Int64)::cublasStatus_t
end

@checked function cublasDtbmv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{Cdouble}, lda::Int64,
                                       x::CuPtr{Cdouble}, incx::Int64)::cublasStatus_t
end

@checked function cublasCtbmv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{cuComplex}, lda::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64)::cublasStatus_t
end

@checked function cublasZtbmv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{cuDoubleComplex},
                                       lda::Int64, x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasStpmv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasStpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{Cfloat}, x::CuPtr{Cfloat},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasDtpmv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{Cdouble}, x::CuPtr{Cdouble},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasCtpmv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasZtpmv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasStrsv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStrsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{Cfloat}, lda::Int64,
                                       x::CuPtr{Cfloat}, incx::Int64)::cublasStatus_t
end

@checked function cublasDtrsv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtrsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{Cdouble}, lda::Int64,
                                       x::CuPtr{Cdouble}, incx::Int64)::cublasStatus_t
end

@checked function cublasCtrsv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtrsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{cuComplex}, lda::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64)::cublasStatus_t
end

@checked function cublasZtrsv_v2_64(handle, uplo, trans, diag, n, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtrsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasStpsv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasStpsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{Cfloat}, x::CuPtr{Cfloat},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasDtpsv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtpsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{Cdouble}, x::CuPtr{Cdouble},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasCtpsv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtpsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasZtpsv_v2_64(handle, uplo, trans, diag, n, AP, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtpsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, AP::CuPtr{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasStbsv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasStbsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{Cfloat}, lda::Int64,
                                       x::CuPtr{Cfloat}, incx::Int64)::cublasStatus_t
end

@checked function cublasDtbsv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasDtbsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{Cdouble}, lda::Int64,
                                       x::CuPtr{Cdouble}, incx::Int64)::cublasStatus_t
end

@checked function cublasCtbsv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasCtbsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{cuComplex}, lda::Int64,
                                       x::CuPtr{cuComplex}, incx::Int64)::cublasStatus_t
end

@checked function cublasZtbsv_v2_64(handle, uplo, trans, diag, n, k, A, lda, x, incx)
    initialize_context()
    @ccall libcublas.cublasZtbsv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, diag::cublasDiagType_t,
                                       n::Int64, k::Int64, A::CuPtr{cuDoubleComplex},
                                       lda::Int64, x::CuPtr{cuDoubleComplex},
                                       incx::Int64)::cublasStatus_t
end

@checked function cublasSsymv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSsymv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cfloat},
                                       A::CuPtr{Cfloat}, lda::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, beta::RefOrCuRef{Cfloat},
                                       y::CuPtr{Cfloat}, incy::Int64)::cublasStatus_t
end

@checked function cublasDsymv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDsymv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cdouble},
                                       A::CuPtr{Cdouble}, lda::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, beta::RefOrCuRef{Cdouble},
                                       y::CuPtr{Cdouble}, incy::Int64)::cublasStatus_t
end

@checked function cublasCsymv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasCsymv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       A::CuPtr{cuComplex}, lda::Int64, x::CuPtr{cuComplex},
                                       incx::Int64, beta::RefOrCuRef{cuComplex},
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZsymv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZsymv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasChemv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasChemv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       A::CuPtr{cuComplex}, lda::Int64, x::CuPtr{cuComplex},
                                       incx::Int64, beta::RefOrCuRef{cuComplex},
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZhemv_v2_64(handle, uplo, n, alpha, A, lda, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZhemv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasSsbmv_v2_64(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasSsbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, k::Int64, alpha::RefOrCuRef{Cfloat},
                                       A::CuPtr{Cfloat}, lda::Int64, x::CuPtr{Cfloat},
                                       incx::Int64, beta::RefOrCuRef{Cfloat},
                                       y::CuPtr{Cfloat}, incy::Int64)::cublasStatus_t
end

@checked function cublasDsbmv_v2_64(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasDsbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, k::Int64, alpha::RefOrCuRef{Cdouble},
                                       A::CuPtr{Cdouble}, lda::Int64, x::CuPtr{Cdouble},
                                       incx::Int64, beta::RefOrCuRef{Cdouble},
                                       y::CuPtr{Cdouble}, incy::Int64)::cublasStatus_t
end

@checked function cublasChbmv_v2_64(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasChbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, k::Int64, alpha::RefOrCuRef{cuComplex},
                                       A::CuPtr{cuComplex}, lda::Int64, x::CuPtr{cuComplex},
                                       incx::Int64, beta::RefOrCuRef{cuComplex},
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZhbmv_v2_64(handle, uplo, n, k, alpha, A, lda, x, incx, beta, y,
                                    incy)
    initialize_context()
    @ccall libcublas.cublasZhbmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, k::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasSspmv_v2_64(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasSspmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cfloat},
                                       AP::CuPtr{Cfloat}, x::CuPtr{Cfloat}, incx::Int64,
                                       beta::RefOrCuRef{Cfloat}, y::CuPtr{Cfloat},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasDspmv_v2_64(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasDspmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cdouble},
                                       AP::CuPtr{Cdouble}, x::CuPtr{Cdouble}, incx::Int64,
                                       beta::RefOrCuRef{Cdouble}, y::CuPtr{Cdouble},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasChpmv_v2_64(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasChpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       AP::CuPtr{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64, beta::RefOrCuRef{cuComplex},
                                       y::CuPtr{cuComplex}, incy::Int64)::cublasStatus_t
end

@checked function cublasZhpmv_v2_64(handle, uplo, n, alpha, AP, x, incx, beta, y, incy)
    initialize_context()
    @ccall libcublas.cublasZhpmv_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       AP::CuPtr{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       y::CuPtr{cuDoubleComplex},
                                       incy::Int64)::cublasStatus_t
end

@checked function cublasSger_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasSger_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                      alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                      incx::Int64, y::CuPtr{Cfloat}, incy::Int64,
                                      A::CuPtr{Cfloat}, lda::Int64)::cublasStatus_t
end

@checked function cublasDger_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasDger_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                      alpha::RefOrCuRef{Cdouble}, x::CuPtr{Cdouble},
                                      incx::Int64, y::CuPtr{Cdouble}, incy::Int64,
                                      A::CuPtr{Cdouble}, lda::Int64)::cublasStatus_t
end

@checked function cublasCgeru_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCgeru_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64, y::CuPtr{cuComplex}, incy::Int64,
                                       A::CuPtr{cuComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasCgerc_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCgerc_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, x::CuPtr{cuComplex},
                                       incx::Int64, y::CuPtr{cuComplex}, incy::Int64,
                                       A::CuPtr{cuComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasZgeru_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZgeru_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       A::CuPtr{cuDoubleComplex},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasZgerc_v2_64(handle, m, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZgerc_v2_64(handle::cublasHandle_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       A::CuPtr{cuDoubleComplex},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasSsyr_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasSsyr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                      incx::Int64, A::CuPtr{Cfloat},
                                      lda::Int64)::cublasStatus_t
end

@checked function cublasDsyr_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasDsyr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cdouble},
                                      x::CuPtr{Cdouble}, incx::Int64, A::CuPtr{Cdouble},
                                      lda::Int64)::cublasStatus_t
end

@checked function cublasCsyr_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasCsyr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{cuComplex},
                                      x::CuPtr{cuComplex}, incx::Int64, A::CuPtr{cuComplex},
                                      lda::Int64)::cublasStatus_t
end

@checked function cublasZsyr_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasZsyr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                      x::CuPtr{cuDoubleComplex}, incx::Int64,
                                      A::CuPtr{cuDoubleComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasCher_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasCher_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cfloat},
                                      x::CuPtr{cuComplex}, incx::Int64, A::CuPtr{cuComplex},
                                      lda::Int64)::cublasStatus_t
end

@checked function cublasZher_v2_64(handle, uplo, n, alpha, x, incx, A, lda)
    initialize_context()
    @ccall libcublas.cublasZher_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cdouble},
                                      x::CuPtr{cuDoubleComplex}, incx::Int64,
                                      A::CuPtr{cuDoubleComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasSspr_v2_64(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasSspr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cfloat}, x::CuPtr{Cfloat},
                                      incx::Int64, AP::CuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDspr_v2_64(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasDspr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cdouble},
                                      x::CuPtr{Cdouble}, incx::Int64,
                                      AP::CuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasChpr_v2_64(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasChpr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cfloat},
                                      x::CuPtr{cuComplex}, incx::Int64,
                                      AP::CuPtr{cuComplex})::cublasStatus_t
end

@checked function cublasZhpr_v2_64(handle, uplo, n, alpha, x, incx, AP)
    initialize_context()
    @ccall libcublas.cublasZhpr_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      n::Int64, alpha::RefOrCuRef{Cdouble},
                                      x::CuPtr{cuDoubleComplex}, incx::Int64,
                                      AP::CuPtr{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSsyr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasSsyr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cfloat},
                                       x::CuPtr{Cfloat}, incx::Int64, y::CuPtr{Cfloat},
                                       incy::Int64, A::CuPtr{Cfloat},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasDsyr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasDsyr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cdouble},
                                       x::CuPtr{Cdouble}, incx::Int64, y::CuPtr{Cdouble},
                                       incy::Int64, A::CuPtr{Cdouble},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasCsyr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCsyr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       A::CuPtr{cuComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasZsyr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZsyr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       A::CuPtr{cuDoubleComplex},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasCher2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasCher2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       A::CuPtr{cuComplex}, lda::Int64)::cublasStatus_t
end

@checked function cublasZher2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, A, lda)
    initialize_context()
    @ccall libcublas.cublasZher2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       A::CuPtr{cuDoubleComplex},
                                       lda::Int64)::cublasStatus_t
end

@checked function cublasSspr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasSspr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cfloat},
                                       x::CuPtr{Cfloat}, incx::Int64, y::CuPtr{Cfloat},
                                       incy::Int64, AP::CuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDspr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasDspr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{Cdouble},
                                       x::CuPtr{Cdouble}, incx::Int64, y::CuPtr{Cdouble},
                                       incy::Int64, AP::CuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasChpr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasChpr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuComplex},
                                       x::CuPtr{cuComplex}, incx::Int64,
                                       y::CuPtr{cuComplex}, incy::Int64,
                                       AP::CuPtr{cuComplex})::cublasStatus_t
end

@checked function cublasZhpr2_v2_64(handle, uplo, n, alpha, x, incx, y, incy, AP)
    initialize_context()
    @ccall libcublas.cublasZhpr2_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       n::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       x::CuPtr{cuDoubleComplex}, incx::Int64,
                                       y::CuPtr{cuDoubleComplex}, incy::Int64,
                                       AP::CuPtr{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSgemm_v2_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                    beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSgemm_v2_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                       transb::cublasOperation_t, m::Int64, n::Int64,
                                       k::Int64, alpha::RefOrCuRef{Cfloat},
                                       A::CuPtr{Cfloat}, lda::Int64, B::CuPtr{Cfloat},
                                       ldb::Int64, beta::RefOrCuRef{Cfloat},
                                       C::CuPtr{Cfloat}, ldc::Int64)::cublasStatus_t
end

@checked function cublasDgemm_v2_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                    beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDgemm_v2_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                       transb::cublasOperation_t, m::Int64, n::Int64,
                                       k::Int64, alpha::RefOrCuRef{Cdouble},
                                       A::CuPtr{Cdouble}, lda::Int64, B::CuPtr{Cdouble},
                                       ldb::Int64, beta::RefOrCuRef{Cdouble},
                                       C::CuPtr{Cdouble}, ldc::Int64)::cublasStatus_t
end

@checked function cublasCgemm_v2_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                    beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm_v2_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                       transb::cublasOperation_t, m::Int64, n::Int64,
                                       k::Int64, alpha::RefOrCuRef{cuComplex},
                                       A::CuPtr{cuComplex}, lda::Int64, B::CuPtr{cuComplex},
                                       ldb::Int64, beta::RefOrCuRef{cuComplex},
                                       C::CuPtr{cuComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasZgemm_v2_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                    beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZgemm_v2_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                       transb::cublasOperation_t, m::Int64, n::Int64,
                                       k::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasSsyrk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSsyrk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                       lda::Int64, beta::RefOrCuRef{Cfloat},
                                       C::CuPtr{Cfloat}, ldc::Int64)::cublasStatus_t
end

@checked function cublasDsyrk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDsyrk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                       lda::Int64, beta::RefOrCuRef{Cdouble},
                                       C::CuPtr{Cdouble}, ldc::Int64)::cublasStatus_t
end

@checked function cublasCsyrk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, beta::RefOrCuRef{cuComplex},
                                       C::CuPtr{cuComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasZsyrk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZsyrk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasCherk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCherk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{cuComplex},
                                       lda::Int64, beta::RefOrCuRef{Cfloat},
                                       C::CuPtr{cuComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasZherk_v2_64(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZherk_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                       trans::cublasOperation_t, n::Int64, k::Int64,
                                       alpha::RefOrCuRef{Cdouble},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       beta::RefOrCuRef{Cdouble}, C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasSsyr2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasSsyr2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                        lda::Int64, B::CuPtr{Cfloat}, ldb::Int64,
                                        beta::RefOrCuRef{Cfloat}, C::CuPtr{Cfloat},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasDsyr2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasDsyr2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                        lda::Int64, B::CuPtr{Cdouble}, ldb::Int64,
                                        beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasCsyr2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyr2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                        lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                        beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasZsyr2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasZsyr2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{cuDoubleComplex},
                                        A::CuPtr{cuDoubleComplex}, lda::Int64,
                                        B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                        beta::RefOrCuRef{cuDoubleComplex},
                                        C::CuPtr{cuDoubleComplex},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasCher2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasCher2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                        lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                        beta::RefOrCuRef{Cfloat}, C::CuPtr{cuComplex},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasZher2k_v2_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta,
                                     C, ldc)
    initialize_context()
    @ccall libcublas.cublasZher2k_v2_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{cuDoubleComplex},
                                        A::CuPtr{cuDoubleComplex}, lda::Int64,
                                        B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                        beta::RefOrCuRef{Cdouble},
                                        C::CuPtr{cuDoubleComplex},
                                        ldc::Int64)::cublasStatus_t
end

@checked function cublasSsymm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasSsymm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                       lda::Int64, B::CuPtr{Cfloat}, ldb::Int64,
                                       beta::RefOrCuRef{Cfloat}, C::CuPtr{Cfloat},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasDsymm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasDsymm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                       lda::Int64, B::CuPtr{Cdouble}, ldb::Int64,
                                       beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasCsymm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasCsymm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                       beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasZsymm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasZsymm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasChemm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasChemm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                       beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasZhemm_v2_64(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta,
                                    C, ldc)
    initialize_context()
    @ccall libcublas.cublasZhemm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                       beta::RefOrCuRef{cuDoubleComplex},
                                       C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@checked function cublasStrsm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb)
    initialize_context()
    @ccall libcublas.cublasStrsm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                       lda::Int64, B::CuPtr{Cfloat},
                                       ldb::Int64)::cublasStatus_t
end

@checked function cublasDtrsm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb)
    initialize_context()
    @ccall libcublas.cublasDtrsm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                       lda::Int64, B::CuPtr{Cdouble},
                                       ldb::Int64)::cublasStatus_t
end

@checked function cublasCtrsm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb)
    initialize_context()
    @ccall libcublas.cublasCtrsm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, B::CuPtr{cuComplex},
                                       ldb::Int64)::cublasStatus_t
end

@checked function cublasZtrsm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb)
    initialize_context()
    @ccall libcublas.cublasZtrsm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       B::CuPtr{cuDoubleComplex},
                                       ldb::Int64)::cublasStatus_t
end

@checked function cublasStrmm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasStrmm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                       lda::Int64, B::CuPtr{Cfloat}, ldb::Int64,
                                       C::CuPtr{Cfloat}, ldc::Int64)::cublasStatus_t
end

@checked function cublasDtrmm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDtrmm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                       lda::Int64, B::CuPtr{Cdouble}, ldb::Int64,
                                       C::CuPtr{Cdouble}, ldc::Int64)::cublasStatus_t
end

@checked function cublasCtrmm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCtrmm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                       lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                       C::CuPtr{cuComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasZtrmm_v2_64(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                    ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZtrmm_v2_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                       uplo::cublasFillMode_t, trans::cublasOperation_t,
                                       diag::cublasDiagType_t, m::Int64, n::Int64,
                                       alpha::RefOrCuRef{cuDoubleComplex},
                                       A::CuPtr{cuDoubleComplex}, lda::Int64,
                                       B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                       C::CuPtr{cuDoubleComplex},
                                       ldc::Int64)::cublasStatus_t
end

@cenum cublasAtomicsMode_t::UInt32 begin
    CUBLAS_ATOMICS_NOT_ALLOWED = 0
    CUBLAS_ATOMICS_ALLOWED = 1
end

@cenum cublasGemmAlgo_t::Int32 begin
    CUBLAS_GEMM_DFALT = -1
    CUBLAS_GEMM_DEFAULT = -1
    CUBLAS_GEMM_ALGO0 = 0
    CUBLAS_GEMM_ALGO1 = 1
    CUBLAS_GEMM_ALGO2 = 2
    CUBLAS_GEMM_ALGO3 = 3
    CUBLAS_GEMM_ALGO4 = 4
    CUBLAS_GEMM_ALGO5 = 5
    CUBLAS_GEMM_ALGO6 = 6
    CUBLAS_GEMM_ALGO7 = 7
    CUBLAS_GEMM_ALGO8 = 8
    CUBLAS_GEMM_ALGO9 = 9
    CUBLAS_GEMM_ALGO10 = 10
    CUBLAS_GEMM_ALGO11 = 11
    CUBLAS_GEMM_ALGO12 = 12
    CUBLAS_GEMM_ALGO13 = 13
    CUBLAS_GEMM_ALGO14 = 14
    CUBLAS_GEMM_ALGO15 = 15
    CUBLAS_GEMM_ALGO16 = 16
    CUBLAS_GEMM_ALGO17 = 17
    CUBLAS_GEMM_ALGO18 = 18
    CUBLAS_GEMM_ALGO19 = 19
    CUBLAS_GEMM_ALGO20 = 20
    CUBLAS_GEMM_ALGO21 = 21
    CUBLAS_GEMM_ALGO22 = 22
    CUBLAS_GEMM_ALGO23 = 23
    CUBLAS_GEMM_DEFAULT_TENSOR_OP = 99
    CUBLAS_GEMM_DFALT_TENSOR_OP = 99
    CUBLAS_GEMM_ALGO0_TENSOR_OP = 100
    CUBLAS_GEMM_ALGO1_TENSOR_OP = 101
    CUBLAS_GEMM_ALGO2_TENSOR_OP = 102
    CUBLAS_GEMM_ALGO3_TENSOR_OP = 103
    CUBLAS_GEMM_ALGO4_TENSOR_OP = 104
    CUBLAS_GEMM_ALGO5_TENSOR_OP = 105
    CUBLAS_GEMM_ALGO6_TENSOR_OP = 106
    CUBLAS_GEMM_ALGO7_TENSOR_OP = 107
    CUBLAS_GEMM_ALGO8_TENSOR_OP = 108
    CUBLAS_GEMM_ALGO9_TENSOR_OP = 109
    CUBLAS_GEMM_ALGO10_TENSOR_OP = 110
    CUBLAS_GEMM_ALGO11_TENSOR_OP = 111
    CUBLAS_GEMM_ALGO12_TENSOR_OP = 112
    CUBLAS_GEMM_ALGO13_TENSOR_OP = 113
    CUBLAS_GEMM_ALGO14_TENSOR_OP = 114
    CUBLAS_GEMM_ALGO15_TENSOR_OP = 115
end

@cenum cublasMath_t::UInt32 begin
    CUBLAS_DEFAULT_MATH = 0
    CUBLAS_TENSOR_OP_MATH = 1
    CUBLAS_PEDANTIC_MATH = 2
    CUBLAS_TF32_TENSOR_OP_MATH = 3
    CUBLAS_MATH_DISALLOW_REDUCED_PRECISION_REDUCTION = 16
end

const cublasDataType_t = cudaDataType

@cenum cublasComputeType_t::UInt32 begin
    CUBLAS_COMPUTE_16F = 64
    CUBLAS_COMPUTE_16F_PEDANTIC = 65
    CUBLAS_COMPUTE_32F = 68
    CUBLAS_COMPUTE_32F_PEDANTIC = 69
    CUBLAS_COMPUTE_32F_FAST_16F = 74
    CUBLAS_COMPUTE_32F_FAST_16BF = 75
    CUBLAS_COMPUTE_32F_FAST_TF32 = 77
    CUBLAS_COMPUTE_64F = 70
    CUBLAS_COMPUTE_64F_PEDANTIC = 71
    CUBLAS_COMPUTE_32I = 72
    CUBLAS_COMPUTE_32I_PEDANTIC = 73
end

# typedef void ( * cublasLogCallback ) ( const char * msg )
const cublasLogCallback = Ptr{Cvoid}

@checked function cublasGetProperty(type, value)
    @ccall libcublas.cublasGetProperty(type::libraryPropertyType,
                                       value::Ref{Cint})::cublasStatus_t
end

function cublasGetCudartVersion()
    @ccall libcublas.cublasGetCudartVersion()::Csize_t
end

@checked function cublasGetAtomicsMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasGetAtomicsMode(handle::cublasHandle_t,
                                          mode::Ref{cublasAtomicsMode_t})::cublasStatus_t
end

@checked function cublasSetAtomicsMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasSetAtomicsMode(handle::cublasHandle_t,
                                          mode::cublasAtomicsMode_t)::cublasStatus_t
end

@checked function cublasGetMathMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasGetMathMode(handle::cublasHandle_t,
                                       mode::Ref{UInt32})::cublasStatus_t
end

@checked function cublasSetMathMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasSetMathMode(handle::cublasHandle_t,
                                       mode::cublasMath_t)::cublasStatus_t
end

@checked function cublasGetSmCountTarget(handle, smCountTarget)
    initialize_context()
    @ccall libcublas.cublasGetSmCountTarget(handle::cublasHandle_t,
                                            smCountTarget::Ptr{Cint})::cublasStatus_t
end

@checked function cublasSetSmCountTarget(handle, smCountTarget)
    initialize_context()
    @ccall libcublas.cublasSetSmCountTarget(handle::cublasHandle_t,
                                            smCountTarget::Cint)::cublasStatus_t
end

function cublasGetStatusName(status)
    initialize_context()
    @ccall libcublas.cublasGetStatusName(status::cublasStatus_t)::Cstring
end

function cublasGetStatusString(status)
    initialize_context()
    @ccall libcublas.cublasGetStatusString(status::cublasStatus_t)::Cstring
end

@checked function cublasLoggerConfigure(logIsOn, logToStdOut, logToStdErr, logFileName)
    initialize_context()
    @ccall libcublas.cublasLoggerConfigure(logIsOn::Cint, logToStdOut::Cint,
                                           logToStdErr::Cint,
                                           logFileName::Cstring)::cublasStatus_t
end

@checked function cublasSetLoggerCallback(userCallback)
    @ccall libcublas.cublasSetLoggerCallback(userCallback::cublasLogCallback)::cublasStatus_t
end

@checked function cublasGetLoggerCallback(userCallback)
    @ccall libcublas.cublasGetLoggerCallback(userCallback::Ref{cublasLogCallback})::cublasStatus_t
end

@checked function cublasSetVector(n, elemSize, x, incx, devicePtr, incy)
    initialize_context()
    @ccall libcublas.cublasSetVector(n::Cint, elemSize::Cint, x::Ptr{Cvoid}, incx::Cint,
                                     devicePtr::CuPtr{Cvoid}, incy::Cint)::cublasStatus_t
end

@checked function cublasSetVector_64(n, elemSize, x, incx, devicePtr, incy)
    initialize_context()
    @ccall libcublas.cublasSetVector_64(n::Int64, elemSize::Int64, x::Ptr{Cvoid},
                                        incx::Int64, devicePtr::CuPtr{Cvoid},
                                        incy::Int64)::cublasStatus_t
end

@checked function cublasGetVector(n, elemSize, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasGetVector(n::Cint, elemSize::Cint, x::CuPtr{Cvoid}, incx::Cint,
                                     y::Ptr{Cvoid}, incy::Cint)::cublasStatus_t
end

@checked function cublasGetVector_64(n, elemSize, x, incx, y, incy)
    initialize_context()
    @ccall libcublas.cublasGetVector_64(n::Int64, elemSize::Int64, x::CuPtr{Cvoid},
                                        incx::Int64, y::Ptr{Cvoid},
                                        incy::Int64)::cublasStatus_t
end

@checked function cublasSetMatrix(rows, cols, elemSize, A, lda, B, ldb)
    initialize_context()
    @ccall libcublas.cublasSetMatrix(rows::Cint, cols::Cint, elemSize::Cint, A::Ptr{Cvoid},
                                     lda::Cint, B::CuPtr{Cvoid}, ldb::Cint)::cublasStatus_t
end

@checked function cublasSetMatrix_64(rows, cols, elemSize, A, lda, B, ldb)
    initialize_context()
    @ccall libcublas.cublasSetMatrix_64(rows::Int64, cols::Int64, elemSize::Int64,
                                        A::Ptr{Cvoid}, lda::Int64, B::CuPtr{Cvoid},
                                        ldb::Int64)::cublasStatus_t
end

@checked function cublasGetMatrix(rows, cols, elemSize, A, lda, B, ldb)
    initialize_context()
    @ccall libcublas.cublasGetMatrix(rows::Cint, cols::Cint, elemSize::Cint,
                                     A::CuPtr{Cvoid}, lda::Cint, B::Ptr{Cvoid},
                                     ldb::Cint)::cublasStatus_t
end

@checked function cublasGetMatrix_64(rows, cols, elemSize, A, lda, B, ldb)
    initialize_context()
    @ccall libcublas.cublasGetMatrix_64(rows::Int64, cols::Int64, elemSize::Int64,
                                        A::CuPtr{Cvoid}, lda::Int64, B::Ptr{Cvoid},
                                        ldb::Int64)::cublasStatus_t
end

@checked function cublasSetVectorAsync(n, elemSize, hostPtr, incx, devicePtr, incy, stream)
    initialize_context()
    @ccall libcublas.cublasSetVectorAsync(n::Cint, elemSize::Cint, hostPtr::Ptr{Cvoid},
                                          incx::Cint, devicePtr::CuPtr{Cvoid}, incy::Cint,
                                          stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasSetVectorAsync_64(n, elemSize, hostPtr, incx, devicePtr, incy,
                                          stream)
    initialize_context()
    @ccall libcublas.cublasSetVectorAsync_64(n::Int64, elemSize::Int64, hostPtr::Ptr{Cvoid},
                                             incx::Int64, devicePtr::CuPtr{Cvoid},
                                             incy::Int64,
                                             stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasGetVectorAsync(n, elemSize, devicePtr, incx, hostPtr, incy, stream)
    initialize_context()
    @ccall libcublas.cublasGetVectorAsync(n::Cint, elemSize::Cint, devicePtr::CuPtr{Cvoid},
                                          incx::Cint, hostPtr::Ptr{Cvoid}, incy::Cint,
                                          stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasGetVectorAsync_64(n, elemSize, devicePtr, incx, hostPtr, incy,
                                          stream)
    initialize_context()
    @ccall libcublas.cublasGetVectorAsync_64(n::Int64, elemSize::Int64,
                                             devicePtr::CuPtr{Cvoid}, incx::Int64,
                                             hostPtr::Ptr{Cvoid}, incy::Int64,
                                             stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasSetMatrixAsync(rows, cols, elemSize, A, lda, B, ldb, stream)
    initialize_context()
    @ccall libcublas.cublasSetMatrixAsync(rows::Cint, cols::Cint, elemSize::Cint,
                                          A::Ptr{Cvoid}, lda::Cint, B::CuPtr{Cvoid},
                                          ldb::Cint, stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasSetMatrixAsync_64(rows, cols, elemSize, A, lda, B, ldb, stream)
    initialize_context()
    @ccall libcublas.cublasSetMatrixAsync_64(rows::Int64, cols::Int64, elemSize::Int64,
                                             A::Ptr{Cvoid}, lda::Int64, B::CuPtr{Cvoid},
                                             ldb::Int64,
                                             stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasGetMatrixAsync(rows, cols, elemSize, A, lda, B, ldb, stream)
    initialize_context()
    @ccall libcublas.cublasGetMatrixAsync(rows::Cint, cols::Cint, elemSize::Cint,
                                          A::CuPtr{Cvoid}, lda::Cint, B::Ptr{Cvoid},
                                          ldb::Cint, stream::cudaStream_t)::cublasStatus_t
end

@checked function cublasGetMatrixAsync_64(rows, cols, elemSize, A, lda, B, ldb, stream)
    initialize_context()
    @ccall libcublas.cublasGetMatrixAsync_64(rows::Int64, cols::Int64, elemSize::Int64,
                                             A::CuPtr{Cvoid}, lda::Int64, B::Ptr{Cvoid},
                                             ldb::Int64,
                                             stream::cudaStream_t)::cublasStatus_t
end

function cublasXerbla(srName, info)
    initialize_context()
    @ccall libcublas.cublasXerbla(srName::Cstring, info::Cint)::Cvoid
end

@checked function cublasNrm2Ex(handle, n, x, xType, incx, result, resultType, executionType)
    initialize_context()
    @ccall libcublas.cublasNrm2Ex(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint,
                                  result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                  executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasNrm2Ex_64(handle, n, x, xType, incx, result, resultType,
                                  executionType)
    initialize_context()
    @ccall libcublas.cublasNrm2Ex_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64,
                                     result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                     executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasDotEx(handle, n, x, xType, incx, y, yType, incy, result, resultType,
                              executionType)
    initialize_context()
    @ccall libcublas.cublasDotEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                 xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                 yType::cudaDataType, incy::Cint, result::PtrOrCuPtr{Cvoid},
                                 resultType::cudaDataType,
                                 executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasDotEx_64(handle, n, x, xType, incx, y, yType, incy, result,
                                 resultType, executionType)
    initialize_context()
    @ccall libcublas.cublasDotEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                    xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                    yType::cudaDataType, incy::Int64,
                                    result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                    executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasDotcEx(handle, n, x, xType, incx, y, yType, incy, result,
                               resultType, executionType)
    initialize_context()
    @ccall libcublas.cublasDotcEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                  yType::cudaDataType, incy::Cint,
                                  result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                  executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasDotcEx_64(handle, n, x, xType, incx, y, yType, incy, result,
                                  resultType, executionType)
    initialize_context()
    @ccall libcublas.cublasDotcEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                     yType::cudaDataType, incy::Int64,
                                     result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                     executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasScalEx(handle, n, alpha, alphaType, x, xType, incx, executionType)
    initialize_context()
    @ccall libcublas.cublasScalEx(handle::cublasHandle_t, n::Cint, alpha::PtrOrCuPtr{Cvoid},
                                  alphaType::cudaDataType, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint,
                                  executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasScalEx_64(handle, n, alpha, alphaType, x, xType, incx,
                                  executionType)
    initialize_context()
    @ccall libcublas.cublasScalEx_64(handle::cublasHandle_t, n::Int64,
                                     alpha::PtrOrCuPtr{Cvoid}, alphaType::cudaDataType,
                                     x::CuPtr{Cvoid}, xType::cudaDataType, incx::Int64,
                                     executionType::cudaDataType)::cublasStatus_t
end

@checked function cublasAxpyEx(handle, n, alpha, alphaType, x, xType, incx, y, yType, incy,
                               executiontype)
    initialize_context()
    @ccall libcublas.cublasAxpyEx(handle::cublasHandle_t, n::Cint, alpha::PtrOrCuPtr{Cvoid},
                                  alphaType::cudaDataType, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                  yType::cudaDataType, incy::Cint,
                                  executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasAxpyEx_64(handle, n, alpha, alphaType, x, xType, incx, y, yType,
                                  incy, executiontype)
    initialize_context()
    @ccall libcublas.cublasAxpyEx_64(handle::cublasHandle_t, n::Int64,
                                     alpha::PtrOrCuPtr{Cvoid}, alphaType::cudaDataType,
                                     x::CuPtr{Cvoid}, xType::cudaDataType, incx::Int64,
                                     y::CuPtr{Cvoid}, yType::cudaDataType, incy::Int64,
                                     executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasCopyEx(handle, n, x, xType, incx, y, yType, incy)
    initialize_context()
    @ccall libcublas.cublasCopyEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                  yType::cudaDataType, incy::Cint)::cublasStatus_t
end

@checked function cublasCopyEx_64(handle, n, x, xType, incx, y, yType, incy)
    initialize_context()
    @ccall libcublas.cublasCopyEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                     yType::cudaDataType, incy::Int64)::cublasStatus_t
end

@checked function cublasSwapEx(handle, n, x, xType, incx, y, yType, incy)
    initialize_context()
    @ccall libcublas.cublasSwapEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                  yType::cudaDataType, incy::Cint)::cublasStatus_t
end

@checked function cublasSwapEx_64(handle, n, x, xType, incx, y, yType, incy)
    initialize_context()
    @ccall libcublas.cublasSwapEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                     yType::cudaDataType, incy::Int64)::cublasStatus_t
end

@checked function cublasIamaxEx(handle, n, x, xType, incx, result)
    initialize_context()
    @ccall libcublas.cublasIamaxEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                   xType::cudaDataType, incx::Cint,
                                   result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIamaxEx_64(handle, n, x, xType, incx, result)
    initialize_context()
    @ccall libcublas.cublasIamaxEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                      xType::cudaDataType, incx::Int64,
                                      result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIaminEx(handle, n, x, xType, incx, result)
    initialize_context()
    @ccall libcublas.cublasIaminEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                   xType::cudaDataType, incx::Cint,
                                   result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasIaminEx_64(handle, n, x, xType, incx, result)
    initialize_context()
    @ccall libcublas.cublasIaminEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                      xType::cudaDataType, incx::Int64,
                                      result::RefOrCuRef{Cint})::cublasStatus_t
end

@checked function cublasAsumEx(handle, n, x, xType, incx, result, resultType, executiontype)
    initialize_context()
    @ccall libcublas.cublasAsumEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint,
                                  result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                  executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasAsumEx_64(handle, n, x, xType, incx, result, resultType,
                                  executiontype)
    initialize_context()
    @ccall libcublas.cublasAsumEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64,
                                     result::PtrOrCuPtr{Cvoid}, resultType::cudaDataType,
                                     executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotEx(handle, n, x, xType, incx, y, yType, incy, c, s, csType,
                              executiontype)
    initialize_context()
    @ccall libcublas.cublasRotEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                 xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                 yType::cudaDataType, incy::Cint, c::PtrOrCuPtr{Cvoid},
                                 s::PtrOrCuPtr{Cvoid}, csType::cudaDataType,
                                 executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotEx_64(handle, n, x, xType, incx, y, yType, incy, c, s, csType,
                                 executiontype)
    initialize_context()
    @ccall libcublas.cublasRotEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                    xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                    yType::cudaDataType, incy::Int64, c::PtrOrCuPtr{Cvoid},
                                    s::PtrOrCuPtr{Cvoid}, csType::cudaDataType,
                                    executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotgEx(handle, a, b, abType, c, s, csType, executiontype)
    initialize_context()
    @ccall libcublas.cublasRotgEx(handle::cublasHandle_t, a::Ptr{Cvoid}, b::Ptr{Cvoid},
                                  abType::cudaDataType, c::PtrOrCuPtr{Cvoid},
                                  s::PtrOrCuPtr{Cvoid}, csType::cudaDataType,
                                  executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotmEx(handle, n, x, xType, incx, y, yType, incy, param, paramType,
                               executiontype)
    initialize_context()
    @ccall libcublas.cublasRotmEx(handle::cublasHandle_t, n::Cint, x::CuPtr{Cvoid},
                                  xType::cudaDataType, incx::Cint, y::CuPtr{Cvoid},
                                  yType::cudaDataType, incy::Cint, param::PtrOrCuPtr{Cvoid},
                                  paramType::cudaDataType,
                                  executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotmEx_64(handle, n, x, xType, incx, y, yType, incy, param,
                                  paramType, executiontype)
    initialize_context()
    @ccall libcublas.cublasRotmEx_64(handle::cublasHandle_t, n::Int64, x::CuPtr{Cvoid},
                                     xType::cudaDataType, incx::Int64, y::CuPtr{Cvoid},
                                     yType::cudaDataType, incy::Int64,
                                     param::PtrOrCuPtr{Cvoid}, paramType::cudaDataType,
                                     executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasRotmgEx(handle, d1, d1Type, d2, d2Type, x1, x1Type, y1, y1Type,
                                param, paramType, executiontype)
    initialize_context()
    @ccall libcublas.cublasRotmgEx(handle::cublasHandle_t, d1::PtrOrCuPtr{Cvoid},
                                   d1Type::cudaDataType, d2::PtrOrCuPtr{Cvoid},
                                   d2Type::cudaDataType, x1::PtrOrCuPtr{Cvoid},
                                   x1Type::cudaDataType, y1::PtrOrCuPtr{Cvoid},
                                   y1Type::cudaDataType, param::PtrOrCuPtr{Cvoid},
                                   paramType::cudaDataType,
                                   executiontype::cudaDataType)::cublasStatus_t
end

@checked function cublasSgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray, incx,
                                     beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, alpha::Ptr{Cfloat},
                                        Aarray::Ptr{Ptr{Cfloat}}, lda::Cint,
                                        xarray::Ptr{Ptr{Cfloat}}, incx::Cint,
                                        beta::Ptr{Cfloat}, yarray::Ptr{Ptr{Cfloat}},
                                        incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasSgemvBatched_64(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                        incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemvBatched_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                           m::Int64, n::Int64, alpha::Ptr{Cfloat},
                                           Aarray::Ptr{Ptr{Cfloat}}, lda::Int64,
                                           xarray::Ptr{Ptr{Cfloat}}, incx::Int64,
                                           beta::Ptr{Cfloat}, yarray::Ptr{Ptr{Cfloat}},
                                           incy::Int64, batchCount::Int64)::cublasStatus_t
end

@checked function cublasDgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray, incx,
                                     beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, alpha::Ptr{Cdouble},
                                        Aarray::Ptr{Ptr{Cdouble}}, lda::Cint,
                                        xarray::Ptr{Ptr{Cdouble}}, incx::Cint,
                                        beta::Ptr{Cdouble}, yarray::Ptr{Ptr{Cdouble}},
                                        incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasDgemvBatched_64(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                        incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemvBatched_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                           m::Int64, n::Int64, alpha::Ptr{Cdouble},
                                           Aarray::Ptr{Ptr{Cdouble}}, lda::Int64,
                                           xarray::Ptr{Ptr{Cdouble}}, incx::Int64,
                                           beta::Ptr{Cdouble}, yarray::Ptr{Ptr{Cdouble}},
                                           incy::Int64, batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray, incx,
                                     beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, alpha::Ptr{cuComplex},
                                        Aarray::Ptr{Ptr{cuComplex}}, lda::Cint,
                                        xarray::Ptr{Ptr{cuComplex}}, incx::Cint,
                                        beta::Ptr{cuComplex}, yarray::Ptr{Ptr{cuComplex}},
                                        incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemvBatched_64(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                        incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemvBatched_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                           m::Int64, n::Int64, alpha::Ptr{cuComplex},
                                           Aarray::Ptr{Ptr{cuComplex}}, lda::Int64,
                                           xarray::Ptr{Ptr{cuComplex}}, incx::Int64,
                                           beta::Ptr{cuComplex},
                                           yarray::Ptr{Ptr{cuComplex}}, incy::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasZgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray, incx,
                                     beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, alpha::Ptr{cuDoubleComplex},
                                        Aarray::Ptr{Ptr{cuDoubleComplex}}, lda::Cint,
                                        xarray::Ptr{Ptr{cuDoubleComplex}}, incx::Cint,
                                        beta::Ptr{cuDoubleComplex},
                                        yarray::Ptr{Ptr{cuDoubleComplex}}, incy::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasZgemvBatched_64(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                        incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemvBatched_64(handle::cublasHandle_t, trans::cublasOperation_t,
                                           m::Int64, n::Int64, alpha::Ptr{cuDoubleComplex},
                                           Aarray::Ptr{Ptr{cuDoubleComplex}}, lda::Int64,
                                           xarray::Ptr{Ptr{cuDoubleComplex}}, incx::Int64,
                                           beta::Ptr{cuDoubleComplex},
                                           yarray::Ptr{Ptr{cuDoubleComplex}}, incy::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasSgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA, x,
                                            incx, stridex, beta, y, incy, stridey,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemvStridedBatched(handle::cublasHandle_t,
                                               trans::cublasOperation_t, m::Cint, n::Cint,
                                               alpha::Ptr{Cfloat}, A::Ptr{Cfloat},
                                               lda::Cint, strideA::Clonglong,
                                               x::Ptr{Cfloat}, incx::Cint,
                                               stridex::Clonglong, beta::Ptr{Cfloat},
                                               y::Ptr{Cfloat}, incy::Cint,
                                               stridey::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasSgemvStridedBatched_64(handle, trans, m, n, alpha, A, lda, strideA,
                                               x, incx, stridex, beta, y, incy, stridey,
                                               batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemvStridedBatched_64(handle::cublasHandle_t,
                                                  trans::cublasOperation_t, m::Int64,
                                                  n::Int64, alpha::Ptr{Cfloat},
                                                  A::Ptr{Cfloat}, lda::Int64,
                                                  strideA::Clonglong, x::Ptr{Cfloat},
                                                  incx::Int64, stridex::Clonglong,
                                                  beta::Ptr{Cfloat}, y::Ptr{Cfloat},
                                                  incy::Int64, stridey::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasDgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA, x,
                                            incx, stridex, beta, y, incy, stridey,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemvStridedBatched(handle::cublasHandle_t,
                                               trans::cublasOperation_t, m::Cint, n::Cint,
                                               alpha::Ptr{Cdouble}, A::Ptr{Cdouble},
                                               lda::Cint, strideA::Clonglong,
                                               x::Ptr{Cdouble}, incx::Cint,
                                               stridex::Clonglong, beta::Ptr{Cdouble},
                                               y::Ptr{Cdouble}, incy::Cint,
                                               stridey::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasDgemvStridedBatched_64(handle, trans, m, n, alpha, A, lda, strideA,
                                               x, incx, stridex, beta, y, incy, stridey,
                                               batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemvStridedBatched_64(handle::cublasHandle_t,
                                                  trans::cublasOperation_t, m::Int64,
                                                  n::Int64, alpha::Ptr{Cdouble},
                                                  A::Ptr{Cdouble}, lda::Int64,
                                                  strideA::Clonglong, x::Ptr{Cdouble},
                                                  incx::Int64, stridex::Clonglong,
                                                  beta::Ptr{Cdouble}, y::Ptr{Cdouble},
                                                  incy::Int64, stridey::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA, x,
                                            incx, stridex, beta, y, incy, stridey,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemvStridedBatched(handle::cublasHandle_t,
                                               trans::cublasOperation_t, m::Cint, n::Cint,
                                               alpha::Ptr{cuComplex}, A::Ptr{cuComplex},
                                               lda::Cint, strideA::Clonglong,
                                               x::Ptr{cuComplex}, incx::Cint,
                                               stridex::Clonglong, beta::Ptr{cuComplex},
                                               y::Ptr{cuComplex}, incy::Cint,
                                               stridey::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemvStridedBatched_64(handle, trans, m, n, alpha, A, lda, strideA,
                                               x, incx, stridex, beta, y, incy, stridey,
                                               batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemvStridedBatched_64(handle::cublasHandle_t,
                                                  trans::cublasOperation_t, m::Int64,
                                                  n::Int64, alpha::Ptr{cuComplex},
                                                  A::Ptr{cuComplex}, lda::Int64,
                                                  strideA::Clonglong, x::Ptr{cuComplex},
                                                  incx::Int64, stridex::Clonglong,
                                                  beta::Ptr{cuComplex}, y::Ptr{cuComplex},
                                                  incy::Int64, stridey::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasZgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA, x,
                                            incx, stridex, beta, y, incy, stridey,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemvStridedBatched(handle::cublasHandle_t,
                                               trans::cublasOperation_t, m::Cint, n::Cint,
                                               alpha::Ptr{cuDoubleComplex},
                                               A::Ptr{cuDoubleComplex}, lda::Cint,
                                               strideA::Clonglong, x::Ptr{cuDoubleComplex},
                                               incx::Cint, stridex::Clonglong,
                                               beta::Ptr{cuDoubleComplex},
                                               y::Ptr{cuDoubleComplex}, incy::Cint,
                                               stridey::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasZgemvStridedBatched_64(handle, trans, m, n, alpha, A, lda, strideA,
                                               x, incx, stridex, beta, y, incy, stridey,
                                               batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemvStridedBatched_64(handle::cublasHandle_t,
                                                  trans::cublasOperation_t, m::Int64,
                                                  n::Int64, alpha::Ptr{cuDoubleComplex},
                                                  A::Ptr{cuDoubleComplex}, lda::Int64,
                                                  strideA::Clonglong,
                                                  x::Ptr{cuDoubleComplex}, incx::Int64,
                                                  stridex::Clonglong,
                                                  beta::Ptr{cuDoubleComplex},
                                                  y::Ptr{cuDoubleComplex}, incy::Int64,
                                                  stridey::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemm3m(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm3m(handle::cublasHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                   lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                   beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                   ldc::Cint)::cublasStatus_t
end

@checked function cublasCgemm3m_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                   beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm3m_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                      transb::cublasOperation_t, m::Int64, n::Int64,
                                      k::Int64, alpha::RefOrCuRef{cuComplex},
                                      A::CuPtr{cuComplex}, lda::Int64, B::CuPtr{cuComplex},
                                      ldb::Int64, beta::RefOrCuRef{cuComplex},
                                      C::CuPtr{cuComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasCgemm3mEx(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                  Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm3mEx(handle::cublasHandle_t, transa::cublasOperation_t,
                                     transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                     Atype::cudaDataType, lda::Cint, B::CuPtr{Cvoid},
                                     Btype::cudaDataType, ldb::Cint,
                                     beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                     Ctype::cudaDataType, ldc::Cint)::cublasStatus_t
end

@checked function cublasCgemm3mEx_64(handle, transa, transb, m, n, k, alpha, A, Atype, lda,
                                     B, Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemm3mEx_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Int64, n::Int64,
                                        k::Int64, alpha::RefOrCuRef{cuComplex},
                                        A::CuPtr{Cvoid}, Atype::cudaDataType, lda::Int64,
                                        B::CuPtr{Cvoid}, Btype::cudaDataType, ldb::Int64,
                                        beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                        Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasZgemm3m(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZgemm3m(handle::cublasHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::CuPtr{cuDoubleComplex}, lda::Cint,
                                   B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                   beta::RefOrCuRef{cuDoubleComplex},
                                   C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZgemm3m_64(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                   beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZgemm3m_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                      transb::cublasOperation_t, m::Int64, n::Int64,
                                      k::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                      A::CuPtr{cuDoubleComplex}, lda::Int64,
                                      B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                      beta::RefOrCuRef{cuDoubleComplex},
                                      C::CuPtr{cuDoubleComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasSgemmEx(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasSgemmEx(handle::cublasHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                   Atype::cudaDataType, lda::Cint, B::CuPtr{Cvoid},
                                   Btype::cudaDataType, ldb::Cint, beta::RefOrCuRef{Cfloat},
                                   C::CuPtr{Cvoid}, Ctype::cudaDataType,
                                   ldc::Cint)::cublasStatus_t
end

@checked function cublasSgemmEx_64(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                   Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasSgemmEx_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                      transb::cublasOperation_t, m::Int64, n::Int64,
                                      k::Int64, alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                      Atype::cudaDataType, lda::Int64, B::CuPtr{Cvoid},
                                      Btype::cudaDataType, ldb::Int64,
                                      beta::RefOrCuRef{Cfloat}, C::CuPtr{Cvoid},
                                      Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasGemmEx(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                               Btype, ldb, beta, C, Ctype, ldc, computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmEx(handle::cublasHandle_t, transa::cublasOperation_t,
                                  transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                  alpha::PtrOrCuPtr{Cvoid}, A::CuPtr{Cvoid},
                                  Atype::cudaDataType, lda::Cint, B::CuPtr{Cvoid},
                                  Btype::cudaDataType, ldb::Cint, beta::PtrOrCuPtr{Cvoid},
                                  C::CuPtr{Cvoid}, Ctype::cudaDataType, ldc::Cint,
                                  computeType::cublasComputeType_t,
                                  algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasGemmEx_64(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                  Btype, ldb, beta, C, Ctype, ldc, computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmEx_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                     transb::cublasOperation_t, m::Int64, n::Int64,
                                     k::Int64, alpha::PtrOrCuPtr{Cvoid}, A::CuPtr{Cvoid},
                                     Atype::cudaDataType, lda::Int64, B::CuPtr{Cvoid},
                                     Btype::cudaDataType, ldb::Int64,
                                     beta::PtrOrCuPtr{Cvoid}, C::CuPtr{Cvoid},
                                     Ctype::cudaDataType, ldc::Int64,
                                     computeType::cublasComputeType_t,
                                     algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasCgemmEx(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemmEx(handle::cublasHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                   Atype::cudaDataType, lda::Cint, B::CuPtr{Cvoid},
                                   Btype::cudaDataType, ldb::Cint,
                                   beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                   Ctype::cudaDataType, ldc::Cint)::cublasStatus_t
end

@checked function cublasCgemmEx_64(handle, transa, transb, m, n, k, alpha, A, Atype, lda, B,
                                   Btype, ldb, beta, C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCgemmEx_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                      transb::cublasOperation_t, m::Int64, n::Int64,
                                      k::Int64, alpha::RefOrCuRef{cuComplex},
                                      A::CuPtr{Cvoid}, Atype::cudaDataType, lda::Int64,
                                      B::CuPtr{Cvoid}, Btype::cudaDataType, ldb::Int64,
                                      beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                      Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasCsyrkEx(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrkEx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                   Atype::cudaDataType, lda::Cint,
                                   beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                   Ctype::cudaDataType, ldc::Cint)::cublasStatus_t
end

@checked function cublasCsyrkEx_64(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                   Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrkEx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      trans::cublasOperation_t, n::Int64, k::Int64,
                                      alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                      Atype::cudaDataType, lda::Int64,
                                      beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                      Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasCsyrk3mEx(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                  Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrk3mEx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                     Atype::cudaDataType, lda::Cint,
                                     beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                     Ctype::cudaDataType, ldc::Cint)::cublasStatus_t
end

@checked function cublasCsyrk3mEx_64(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta,
                                     C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrk3mEx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{cuComplex}, A::CuPtr{Cvoid},
                                        Atype::cudaDataType, lda::Int64,
                                        beta::RefOrCuRef{cuComplex}, C::CuPtr{Cvoid},
                                        Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasCherkEx(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCherkEx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Cint, k::Cint,
                                   alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                   Atype::cudaDataType, lda::Cint, beta::RefOrCuRef{Cfloat},
                                   C::CuPtr{Cvoid}, Ctype::cudaDataType,
                                   ldc::Cint)::cublasStatus_t
end

@checked function cublasCherkEx_64(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                   Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCherkEx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                      trans::cublasOperation_t, n::Int64, k::Int64,
                                      alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                      Atype::cudaDataType, lda::Int64,
                                      beta::RefOrCuRef{Cfloat}, C::CuPtr{Cvoid},
                                      Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasCherk3mEx(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta, C,
                                  Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCherk3mEx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Cint, k::Cint,
                                     alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                     Atype::cudaDataType, lda::Cint,
                                     beta::RefOrCuRef{Cfloat}, C::CuPtr{Cvoid},
                                     Ctype::cudaDataType, ldc::Cint)::cublasStatus_t
end

@checked function cublasCherk3mEx_64(handle, uplo, trans, n, k, alpha, A, Atype, lda, beta,
                                     C, Ctype, ldc)
    initialize_context()
    @ccall libcublas.cublasCherk3mEx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                        trans::cublasOperation_t, n::Int64, k::Int64,
                                        alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cvoid},
                                        Atype::cudaDataType, lda::Int64,
                                        beta::RefOrCuRef{Cfloat}, C::CuPtr{Cvoid},
                                        Ctype::cudaDataType, ldc::Int64)::cublasStatus_t
end

@checked function cublasSsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasSsyrkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                  B::CuPtr{Cfloat}, ldb::Cint, beta::RefOrCuRef{Cfloat},
                                  C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSsyrkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasSsyrkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat},
                                     lda::Int64, B::CuPtr{Cfloat}, ldb::Int64,
                                     beta::RefOrCuRef{Cfloat}, C::CuPtr{Cfloat},
                                     ldc::Int64)::cublasStatus_t
end

@checked function cublasDsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasDsyrkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble}, lda::Cint,
                                  B::CuPtr{Cdouble}, ldb::Cint, beta::RefOrCuRef{Cdouble},
                                  C::CuPtr{Cdouble}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDsyrkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasDsyrkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                     lda::Int64, B::CuPtr{Cdouble}, ldb::Int64,
                                     beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                     ldc::Int64)::cublasStatus_t
end

@checked function cublasCsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                  lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                  beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                  ldc::Cint)::cublasStatus_t
end

@checked function cublasCsyrkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasCsyrkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                     lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                     beta::RefOrCuRef{cuComplex}, C::CuPtr{cuComplex},
                                     ldc::Int64)::cublasStatus_t
end

@checked function cublasZsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasZsyrkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{cuDoubleComplex},
                                  A::CuPtr{cuDoubleComplex}, lda::Cint,
                                  B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                  beta::RefOrCuRef{cuDoubleComplex},
                                  C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZsyrkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasZsyrkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{cuDoubleComplex},
                                     A::CuPtr{cuDoubleComplex}, lda::Int64,
                                     B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                     beta::RefOrCuRef{cuDoubleComplex},
                                     C::CuPtr{cuDoubleComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasCherkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasCherkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                  lda::Cint, B::CuPtr{cuComplex}, ldb::Cint,
                                  beta::RefOrCuRef{Cfloat}, C::CuPtr{cuComplex},
                                  ldc::Cint)::cublasStatus_t
end

@checked function cublasCherkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasCherkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                     lda::Int64, B::CuPtr{cuComplex}, ldb::Int64,
                                     beta::RefOrCuRef{Cfloat}, C::CuPtr{cuComplex},
                                     ldc::Int64)::cublasStatus_t
end

@checked function cublasZherkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                               ldc)
    initialize_context()
    @ccall libcublas.cublasZherkx(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                  trans::cublasOperation_t, n::Cint, k::Cint,
                                  alpha::RefOrCuRef{cuDoubleComplex},
                                  A::CuPtr{cuDoubleComplex}, lda::Cint,
                                  B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                  beta::RefOrCuRef{Cdouble}, C::CuPtr{cuDoubleComplex},
                                  ldc::Cint)::cublasStatus_t
end

@checked function cublasZherkx_64(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                  ldc)
    initialize_context()
    @ccall libcublas.cublasZherkx_64(handle::cublasHandle_t, uplo::cublasFillMode_t,
                                     trans::cublasOperation_t, n::Int64, k::Int64,
                                     alpha::RefOrCuRef{cuDoubleComplex},
                                     A::CuPtr{cuDoubleComplex}, lda::Int64,
                                     B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                     beta::RefOrCuRef{Cdouble}, C::CuPtr{cuDoubleComplex},
                                     ldc::Int64)::cublasStatus_t
end

@checked function cublasSgemmBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                     Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemmBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Cint, n::Cint,
                                        k::Cint, alpha::RefOrCuRef{Cfloat},
                                        Aarray::CuPtr{Ptr{Cfloat}}, lda::Cint,
                                        Barray::CuPtr{Ptr{Cfloat}}, ldb::Cint,
                                        beta::RefOrCuRef{Cfloat},
                                        Carray::CuPtr{Ptr{Cfloat}}, ldc::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasSgemmBatched_64(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                        Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemmBatched_64(handle::cublasHandle_t,
                                           transa::cublasOperation_t,
                                           transb::cublasOperation_t, m::Int64, n::Int64,
                                           k::Int64, alpha::RefOrCuRef{Cfloat},
                                           Aarray::CuPtr{Ptr{Cfloat}}, lda::Int64,
                                           Barray::CuPtr{Ptr{Cfloat}}, ldb::Int64,
                                           beta::RefOrCuRef{Cfloat},
                                           Carray::CuPtr{Ptr{Cfloat}}, ldc::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasDgemmBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                     Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemmBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Cint, n::Cint,
                                        k::Cint, alpha::RefOrCuRef{Cdouble},
                                        Aarray::CuPtr{Ptr{Cdouble}}, lda::Cint,
                                        Barray::CuPtr{Ptr{Cdouble}}, ldb::Cint,
                                        beta::RefOrCuRef{Cdouble},
                                        Carray::CuPtr{Ptr{Cdouble}}, ldc::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasDgemmBatched_64(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                        Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemmBatched_64(handle::cublasHandle_t,
                                           transa::cublasOperation_t,
                                           transb::cublasOperation_t, m::Int64, n::Int64,
                                           k::Int64, alpha::RefOrCuRef{Cdouble},
                                           Aarray::CuPtr{Ptr{Cdouble}}, lda::Int64,
                                           Barray::CuPtr{Ptr{Cdouble}}, ldb::Int64,
                                           beta::RefOrCuRef{Cdouble},
                                           Carray::CuPtr{Ptr{Cdouble}}, ldc::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemmBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                     Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemmBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Cint, n::Cint,
                                        k::Cint, alpha::RefOrCuRef{cuComplex},
                                        Aarray::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                        Barray::CuPtr{Ptr{cuComplex}}, ldb::Cint,
                                        beta::RefOrCuRef{cuComplex},
                                        Carray::CuPtr{Ptr{cuComplex}}, ldc::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemmBatched_64(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                        Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemmBatched_64(handle::cublasHandle_t,
                                           transa::cublasOperation_t,
                                           transb::cublasOperation_t, m::Int64, n::Int64,
                                           k::Int64, alpha::RefOrCuRef{cuComplex},
                                           Aarray::CuPtr{Ptr{cuComplex}}, lda::Int64,
                                           Barray::CuPtr{Ptr{cuComplex}}, ldb::Int64,
                                           beta::RefOrCuRef{cuComplex},
                                           Carray::CuPtr{Ptr{cuComplex}}, ldc::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemm3mBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                       Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemm3mBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                          transb::cublasOperation_t, m::Cint, n::Cint,
                                          k::Cint, alpha::RefOrCuRef{cuComplex},
                                          Aarray::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                          Barray::CuPtr{Ptr{cuComplex}}, ldb::Cint,
                                          beta::RefOrCuRef{cuComplex},
                                          Carray::CuPtr{Ptr{cuComplex}}, ldc::Cint,
                                          batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemm3mBatched_64(handle, transa, transb, m, n, k, alpha, Aarray,
                                          lda, Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemm3mBatched_64(handle::cublasHandle_t,
                                             transa::cublasOperation_t,
                                             transb::cublasOperation_t, m::Int64, n::Int64,
                                             k::Int64, alpha::RefOrCuRef{cuComplex},
                                             Aarray::CuPtr{Ptr{cuComplex}}, lda::Int64,
                                             Barray::CuPtr{Ptr{cuComplex}}, ldb::Int64,
                                             beta::RefOrCuRef{cuComplex},
                                             Carray::CuPtr{Ptr{cuComplex}}, ldc::Int64,
                                             batchCount::Int64)::cublasStatus_t
end

@checked function cublasZgemmBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                     Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemmBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Cint, n::Cint,
                                        k::Cint, alpha::RefOrCuRef{cuDoubleComplex},
                                        Aarray::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                        Barray::CuPtr{Ptr{cuDoubleComplex}}, ldb::Cint,
                                        beta::RefOrCuRef{cuDoubleComplex},
                                        Carray::CuPtr{Ptr{cuDoubleComplex}}, ldc::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasZgemmBatched_64(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                        Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemmBatched_64(handle::cublasHandle_t,
                                           transa::cublasOperation_t,
                                           transb::cublasOperation_t, m::Int64, n::Int64,
                                           k::Int64, alpha::RefOrCuRef{cuDoubleComplex},
                                           Aarray::CuPtr{Ptr{cuDoubleComplex}}, lda::Int64,
                                           Barray::CuPtr{Ptr{cuDoubleComplex}}, ldb::Int64,
                                           beta::RefOrCuRef{cuDoubleComplex},
                                           Carray::CuPtr{Ptr{cuDoubleComplex}}, ldc::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasSgemmStridedBatched(handle, transa, transb, m, n, k, alpha, A, lda,
                                            strideA, B, ldb, strideB, beta, C, ldc, strideC,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemmStridedBatched(handle::cublasHandle_t,
                                               transa::cublasOperation_t,
                                               transb::cublasOperation_t, m::Cint, n::Cint,
                                               k::Cint, alpha::RefOrCuRef{Cfloat},
                                               A::CuPtr{Cfloat}, lda::Cint,
                                               strideA::Clonglong, B::CuPtr{Cfloat},
                                               ldb::Cint, strideB::Clonglong,
                                               beta::RefOrCuRef{Cfloat}, C::CuPtr{Cfloat},
                                               ldc::Cint, strideC::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasSgemmStridedBatched_64(handle, transa, transb, m, n, k, alpha, A,
                                               lda, strideA, B, ldb, strideB, beta, C, ldc,
                                               strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasSgemmStridedBatched_64(handle::cublasHandle_t,
                                                  transa::cublasOperation_t,
                                                  transb::cublasOperation_t, m::Int64,
                                                  n::Int64, k::Int64,
                                                  alpha::RefOrCuRef{Cfloat},
                                                  A::CuPtr{Cfloat}, lda::Int64,
                                                  strideA::Clonglong, B::CuPtr{Cfloat},
                                                  ldb::Int64, strideB::Clonglong,
                                                  beta::RefOrCuRef{Cfloat},
                                                  C::CuPtr{Cfloat}, ldc::Int64,
                                                  strideC::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasDgemmStridedBatched(handle, transa, transb, m, n, k, alpha, A, lda,
                                            strideA, B, ldb, strideB, beta, C, ldc, strideC,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemmStridedBatched(handle::cublasHandle_t,
                                               transa::cublasOperation_t,
                                               transb::cublasOperation_t, m::Cint, n::Cint,
                                               k::Cint, alpha::RefOrCuRef{Cdouble},
                                               A::CuPtr{Cdouble}, lda::Cint,
                                               strideA::Clonglong, B::CuPtr{Cdouble},
                                               ldb::Cint, strideB::Clonglong,
                                               beta::RefOrCuRef{Cdouble}, C::CuPtr{Cdouble},
                                               ldc::Cint, strideC::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasDgemmStridedBatched_64(handle, transa, transb, m, n, k, alpha, A,
                                               lda, strideA, B, ldb, strideB, beta, C, ldc,
                                               strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasDgemmStridedBatched_64(handle::cublasHandle_t,
                                                  transa::cublasOperation_t,
                                                  transb::cublasOperation_t, m::Int64,
                                                  n::Int64, k::Int64,
                                                  alpha::RefOrCuRef{Cdouble},
                                                  A::CuPtr{Cdouble}, lda::Int64,
                                                  strideA::Clonglong, B::CuPtr{Cdouble},
                                                  ldb::Int64, strideB::Clonglong,
                                                  beta::RefOrCuRef{Cdouble},
                                                  C::CuPtr{Cdouble}, ldc::Int64,
                                                  strideC::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemmStridedBatched(handle, transa, transb, m, n, k, alpha, A, lda,
                                            strideA, B, ldb, strideB, beta, C, ldc, strideC,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemmStridedBatched(handle::cublasHandle_t,
                                               transa::cublasOperation_t,
                                               transb::cublasOperation_t, m::Cint, n::Cint,
                                               k::Cint, alpha::RefOrCuRef{cuComplex},
                                               A::CuPtr{cuComplex}, lda::Cint,
                                               strideA::Clonglong, B::CuPtr{cuComplex},
                                               ldb::Cint, strideB::Clonglong,
                                               beta::RefOrCuRef{cuComplex},
                                               C::CuPtr{cuComplex}, ldc::Cint,
                                               strideC::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemmStridedBatched_64(handle, transa, transb, m, n, k, alpha, A,
                                               lda, strideA, B, ldb, strideB, beta, C, ldc,
                                               strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemmStridedBatched_64(handle::cublasHandle_t,
                                                  transa::cublasOperation_t,
                                                  transb::cublasOperation_t, m::Int64,
                                                  n::Int64, k::Int64,
                                                  alpha::RefOrCuRef{cuComplex},
                                                  A::CuPtr{cuComplex}, lda::Int64,
                                                  strideA::Clonglong, B::CuPtr{cuComplex},
                                                  ldb::Int64, strideB::Clonglong,
                                                  beta::RefOrCuRef{cuComplex},
                                                  C::CuPtr{cuComplex}, ldc::Int64,
                                                  strideC::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasCgemm3mStridedBatched(handle, transa, transb, m, n, k, alpha, A,
                                              lda, strideA, B, ldb, strideB, beta, C, ldc,
                                              strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemm3mStridedBatched(handle::cublasHandle_t,
                                                 transa::cublasOperation_t,
                                                 transb::cublasOperation_t, m::Cint,
                                                 n::Cint, k::Cint,
                                                 alpha::RefOrCuRef{cuComplex},
                                                 A::CuPtr{cuComplex}, lda::Cint,
                                                 strideA::Clonglong, B::CuPtr{cuComplex},
                                                 ldb::Cint, strideB::Clonglong,
                                                 beta::RefOrCuRef{cuComplex},
                                                 C::CuPtr{cuComplex}, ldc::Cint,
                                                 strideC::Clonglong,
                                                 batchCount::Cint)::cublasStatus_t
end

@checked function cublasCgemm3mStridedBatched_64(handle, transa, transb, m, n, k, alpha, A,
                                                 lda, strideA, B, ldb, strideB, beta, C,
                                                 ldc, strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasCgemm3mStridedBatched_64(handle::cublasHandle_t,
                                                    transa::cublasOperation_t,
                                                    transb::cublasOperation_t, m::Int64,
                                                    n::Int64, k::Int64,
                                                    alpha::RefOrCuRef{cuComplex},
                                                    A::CuPtr{cuComplex}, lda::Int64,
                                                    strideA::Clonglong, B::CuPtr{cuComplex},
                                                    ldb::Int64, strideB::Clonglong,
                                                    beta::RefOrCuRef{cuComplex},
                                                    C::CuPtr{cuComplex}, ldc::Int64,
                                                    strideC::Clonglong,
                                                    batchCount::Int64)::cublasStatus_t
end

@checked function cublasZgemmStridedBatched(handle, transa, transb, m, n, k, alpha, A, lda,
                                            strideA, B, ldb, strideB, beta, C, ldc, strideC,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemmStridedBatched(handle::cublasHandle_t,
                                               transa::cublasOperation_t,
                                               transb::cublasOperation_t, m::Cint, n::Cint,
                                               k::Cint, alpha::RefOrCuRef{cuDoubleComplex},
                                               A::CuPtr{cuDoubleComplex}, lda::Cint,
                                               strideA::Clonglong,
                                               B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                               strideB::Clonglong,
                                               beta::RefOrCuRef{cuDoubleComplex},
                                               C::CuPtr{cuDoubleComplex}, ldc::Cint,
                                               strideC::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end

@checked function cublasZgemmStridedBatched_64(handle, transa, transb, m, n, k, alpha, A,
                                               lda, strideA, B, ldb, strideB, beta, C, ldc,
                                               strideC, batchCount)
    initialize_context()
    @ccall libcublas.cublasZgemmStridedBatched_64(handle::cublasHandle_t,
                                                  transa::cublasOperation_t,
                                                  transb::cublasOperation_t, m::Int64,
                                                  n::Int64, k::Int64,
                                                  alpha::RefOrCuRef{cuDoubleComplex},
                                                  A::CuPtr{cuDoubleComplex}, lda::Int64,
                                                  strideA::Clonglong,
                                                  B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                                  strideB::Clonglong,
                                                  beta::RefOrCuRef{cuDoubleComplex},
                                                  C::CuPtr{cuDoubleComplex}, ldc::Int64,
                                                  strideC::Clonglong,
                                                  batchCount::Int64)::cublasStatus_t
end

@checked function cublasGemmBatchedEx(handle, transa, transb, m, n, k, alpha, Aarray, Atype,
                                      lda, Barray, Btype, ldb, beta, Carray, Ctype, ldc,
                                      batchCount, computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmBatchedEx(handle::cublasHandle_t, transa::cublasOperation_t,
                                         transb::cublasOperation_t, m::Cint, n::Cint,
                                         k::Cint, alpha::PtrOrCuPtr{Cvoid},
                                         Aarray::CuPtr{Ptr{Cvoid}}, Atype::cudaDataType,
                                         lda::Cint, Barray::CuPtr{Ptr{Cvoid}},
                                         Btype::cudaDataType, ldb::Cint,
                                         beta::PtrOrCuPtr{Cvoid}, Carray::CuPtr{Ptr{Cvoid}},
                                         Ctype::cudaDataType, ldc::Cint, batchCount::Cint,
                                         computeType::cublasComputeType_t,
                                         algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasGemmBatchedEx_64(handle, transa, transb, m, n, k, alpha, Aarray,
                                         Atype, lda, Barray, Btype, ldb, beta, Carray,
                                         Ctype, ldc, batchCount, computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmBatchedEx_64(handle::cublasHandle_t,
                                            transa::cublasOperation_t,
                                            transb::cublasOperation_t, m::Int64, n::Int64,
                                            k::Int64, alpha::PtrOrCuPtr{Cvoid},
                                            Aarray::CuPtr{Ptr{Cvoid}}, Atype::cudaDataType,
                                            lda::Int64, Barray::CuPtr{Ptr{Cvoid}},
                                            Btype::cudaDataType, ldb::Int64,
                                            beta::PtrOrCuPtr{Cvoid},
                                            Carray::CuPtr{Ptr{Cvoid}}, Ctype::cudaDataType,
                                            ldc::Int64, batchCount::Int64,
                                            computeType::cublasComputeType_t,
                                            algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasGemmStridedBatchedEx(handle, transa, transb, m, n, k, alpha, A,
                                             Atype, lda, strideA, B, Btype, ldb, strideB,
                                             beta, C, Ctype, ldc, strideC, batchCount,
                                             computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmStridedBatchedEx(handle::cublasHandle_t,
                                                transa::cublasOperation_t,
                                                transb::cublasOperation_t, m::Cint, n::Cint,
                                                k::Cint, alpha::PtrOrCuPtr{Cvoid},
                                                A::CuPtr{Cvoid}, Atype::cudaDataType,
                                                lda::Cint, strideA::Clonglong,
                                                B::CuPtr{Cvoid}, Btype::cudaDataType,
                                                ldb::Cint, strideB::Clonglong,
                                                beta::PtrOrCuPtr{Cvoid}, C::CuPtr{Cvoid},
                                                Ctype::cudaDataType, ldc::Cint,
                                                strideC::Clonglong, batchCount::Cint,
                                                computeType::cublasComputeType_t,
                                                algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasGemmStridedBatchedEx_64(handle, transa, transb, m, n, k, alpha, A,
                                                Atype, lda, strideA, B, Btype, ldb, strideB,
                                                beta, C, Ctype, ldc, strideC, batchCount,
                                                computeType, algo)
    initialize_context()
    @ccall libcublas.cublasGemmStridedBatchedEx_64(handle::cublasHandle_t,
                                                   transa::cublasOperation_t,
                                                   transb::cublasOperation_t, m::Int64,
                                                   n::Int64, k::Int64,
                                                   alpha::PtrOrCuPtr{Cvoid},
                                                   A::CuPtr{Cvoid}, Atype::cudaDataType,
                                                   lda::Int64, strideA::Clonglong,
                                                   B::CuPtr{Cvoid}, Btype::cudaDataType,
                                                   ldb::Int64, strideB::Clonglong,
                                                   beta::PtrOrCuPtr{Cvoid}, C::CuPtr{Cvoid},
                                                   Ctype::cudaDataType, ldc::Int64,
                                                   strideC::Clonglong, batchCount::Int64,
                                                   computeType::cublasComputeType_t,
                                                   algo::cublasGemmAlgo_t)::cublasStatus_t
end

@checked function cublasSgeam(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb, C,
                              ldc)
    initialize_context()
    @ccall libcublas.cublasSgeam(handle::cublasHandle_t, transa::cublasOperation_t,
                                 transb::cublasOperation_t, m::Cint, n::Cint,
                                 alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Cint,
                                 beta::RefOrCuRef{Cfloat}, B::CuPtr{Cfloat}, ldb::Cint,
                                 C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSgeam_64(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb,
                                 C, ldc)
    initialize_context()
    @ccall libcublas.cublasSgeam_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Int64, n::Int64,
                                    alpha::RefOrCuRef{Cfloat}, A::CuPtr{Cfloat}, lda::Int64,
                                    beta::RefOrCuRef{Cfloat}, B::CuPtr{Cfloat}, ldb::Int64,
                                    C::CuPtr{Cfloat}, ldc::Int64)::cublasStatus_t
end

@checked function cublasDgeam(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb, C,
                              ldc)
    initialize_context()
    @ccall libcublas.cublasDgeam(handle::cublasHandle_t, transa::cublasOperation_t,
                                 transb::cublasOperation_t, m::Cint, n::Cint,
                                 alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble}, lda::Cint,
                                 beta::RefOrCuRef{Cdouble}, B::CuPtr{Cdouble}, ldb::Cint,
                                 C::CuPtr{Cdouble}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDgeam_64(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb,
                                 C, ldc)
    initialize_context()
    @ccall libcublas.cublasDgeam_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Int64, n::Int64,
                                    alpha::RefOrCuRef{Cdouble}, A::CuPtr{Cdouble},
                                    lda::Int64, beta::RefOrCuRef{Cdouble},
                                    B::CuPtr{Cdouble}, ldb::Int64, C::CuPtr{Cdouble},
                                    ldc::Int64)::cublasStatus_t
end

@checked function cublasCgeam(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb, C,
                              ldc)
    initialize_context()
    @ccall libcublas.cublasCgeam(handle::cublasHandle_t, transa::cublasOperation_t,
                                 transb::cublasOperation_t, m::Cint, n::Cint,
                                 alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                 lda::Cint, beta::RefOrCuRef{cuComplex},
                                 B::CuPtr{cuComplex}, ldb::Cint, C::CuPtr{cuComplex},
                                 ldc::Cint)::cublasStatus_t
end

@checked function cublasCgeam_64(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb,
                                 C, ldc)
    initialize_context()
    @ccall libcublas.cublasCgeam_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Int64, n::Int64,
                                    alpha::RefOrCuRef{cuComplex}, A::CuPtr{cuComplex},
                                    lda::Int64, beta::RefOrCuRef{cuComplex},
                                    B::CuPtr{cuComplex}, ldb::Int64, C::CuPtr{cuComplex},
                                    ldc::Int64)::cublasStatus_t
end

@checked function cublasZgeam(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb, C,
                              ldc)
    initialize_context()
    @ccall libcublas.cublasZgeam(handle::cublasHandle_t, transa::cublasOperation_t,
                                 transb::cublasOperation_t, m::Cint, n::Cint,
                                 alpha::RefOrCuRef{cuDoubleComplex},
                                 A::CuPtr{cuDoubleComplex}, lda::Cint,
                                 beta::RefOrCuRef{cuDoubleComplex},
                                 B::CuPtr{cuDoubleComplex}, ldb::Cint,
                                 C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZgeam_64(handle, transa, transb, m, n, alpha, A, lda, beta, B, ldb,
                                 C, ldc)
    initialize_context()
    @ccall libcublas.cublasZgeam_64(handle::cublasHandle_t, transa::cublasOperation_t,
                                    transb::cublasOperation_t, m::Int64, n::Int64,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::CuPtr{cuDoubleComplex}, lda::Int64,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    B::CuPtr{cuDoubleComplex}, ldb::Int64,
                                    C::CuPtr{cuDoubleComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasStrsmBatched(handle, side, uplo, trans, diag, m, n, alpha, A, lda,
                                     B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasStrsmBatched(handle::cublasHandle_t, side::cublasSideMode_t,
                                        uplo::cublasFillMode_t, trans::cublasOperation_t,
                                        diag::cublasDiagType_t, m::Cint, n::Cint,
                                        alpha::RefOrCuRef{Cfloat}, A::CuPtr{Ptr{Cfloat}},
                                        lda::Cint, B::CuPtr{Ptr{Cfloat}}, ldb::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasStrsmBatched_64(handle, side, uplo, trans, diag, m, n, alpha, A,
                                        lda, B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasStrsmBatched_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                           uplo::cublasFillMode_t, trans::cublasOperation_t,
                                           diag::cublasDiagType_t, m::Int64, n::Int64,
                                           alpha::RefOrCuRef{Cfloat}, A::CuPtr{Ptr{Cfloat}},
                                           lda::Int64, B::CuPtr{Ptr{Cfloat}}, ldb::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasDtrsmBatched(handle, side, uplo, trans, diag, m, n, alpha, A, lda,
                                     B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasDtrsmBatched(handle::cublasHandle_t, side::cublasSideMode_t,
                                        uplo::cublasFillMode_t, trans::cublasOperation_t,
                                        diag::cublasDiagType_t, m::Cint, n::Cint,
                                        alpha::RefOrCuRef{Cdouble}, A::CuPtr{Ptr{Cdouble}},
                                        lda::Cint, B::CuPtr{Ptr{Cdouble}}, ldb::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasDtrsmBatched_64(handle, side, uplo, trans, diag, m, n, alpha, A,
                                        lda, B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasDtrsmBatched_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                           uplo::cublasFillMode_t, trans::cublasOperation_t,
                                           diag::cublasDiagType_t, m::Int64, n::Int64,
                                           alpha::RefOrCuRef{Cdouble},
                                           A::CuPtr{Ptr{Cdouble}}, lda::Int64,
                                           B::CuPtr{Ptr{Cdouble}}, ldb::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasCtrsmBatched(handle, side, uplo, trans, diag, m, n, alpha, A, lda,
                                     B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasCtrsmBatched(handle::cublasHandle_t, side::cublasSideMode_t,
                                        uplo::cublasFillMode_t, trans::cublasOperation_t,
                                        diag::cublasDiagType_t, m::Cint, n::Cint,
                                        alpha::RefOrCuRef{cuComplex},
                                        A::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                        B::CuPtr{Ptr{cuComplex}}, ldb::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasCtrsmBatched_64(handle, side, uplo, trans, diag, m, n, alpha, A,
                                        lda, B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasCtrsmBatched_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                           uplo::cublasFillMode_t, trans::cublasOperation_t,
                                           diag::cublasDiagType_t, m::Int64, n::Int64,
                                           alpha::RefOrCuRef{cuComplex},
                                           A::CuPtr{Ptr{cuComplex}}, lda::Int64,
                                           B::CuPtr{Ptr{cuComplex}}, ldb::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasZtrsmBatched(handle, side, uplo, trans, diag, m, n, alpha, A, lda,
                                     B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasZtrsmBatched(handle::cublasHandle_t, side::cublasSideMode_t,
                                        uplo::cublasFillMode_t, trans::cublasOperation_t,
                                        diag::cublasDiagType_t, m::Cint, n::Cint,
                                        alpha::RefOrCuRef{cuDoubleComplex},
                                        A::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                        B::CuPtr{Ptr{cuDoubleComplex}}, ldb::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasZtrsmBatched_64(handle, side, uplo, trans, diag, m, n, alpha, A,
                                        lda, B, ldb, batchCount)
    initialize_context()
    @ccall libcublas.cublasZtrsmBatched_64(handle::cublasHandle_t, side::cublasSideMode_t,
                                           uplo::cublasFillMode_t, trans::cublasOperation_t,
                                           diag::cublasDiagType_t, m::Int64, n::Int64,
                                           alpha::RefOrCuRef{cuDoubleComplex},
                                           A::CuPtr{Ptr{cuDoubleComplex}}, lda::Int64,
                                           B::CuPtr{Ptr{cuDoubleComplex}}, ldb::Int64,
                                           batchCount::Int64)::cublasStatus_t
end

@checked function cublasSdgmm(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSdgmm(handle::cublasHandle_t, mode::cublasSideMode_t, m::Cint,
                                 n::Cint, A::CuPtr{Cfloat}, lda::Cint, x::CuPtr{Cfloat},
                                 incx::Cint, C::CuPtr{Cfloat}, ldc::Cint)::cublasStatus_t
end

@checked function cublasSdgmm_64(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasSdgmm_64(handle::cublasHandle_t, mode::cublasSideMode_t,
                                    m::Int64, n::Int64, A::CuPtr{Cfloat}, lda::Int64,
                                    x::CuPtr{Cfloat}, incx::Int64, C::CuPtr{Cfloat},
                                    ldc::Int64)::cublasStatus_t
end

@checked function cublasDdgmm(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDdgmm(handle::cublasHandle_t, mode::cublasSideMode_t, m::Cint,
                                 n::Cint, A::CuPtr{Cdouble}, lda::Cint, x::CuPtr{Cdouble},
                                 incx::Cint, C::CuPtr{Cdouble}, ldc::Cint)::cublasStatus_t
end

@checked function cublasDdgmm_64(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasDdgmm_64(handle::cublasHandle_t, mode::cublasSideMode_t,
                                    m::Int64, n::Int64, A::CuPtr{Cdouble}, lda::Int64,
                                    x::CuPtr{Cdouble}, incx::Int64, C::CuPtr{Cdouble},
                                    ldc::Int64)::cublasStatus_t
end

@checked function cublasCdgmm(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCdgmm(handle::cublasHandle_t, mode::cublasSideMode_t, m::Cint,
                                 n::Cint, A::CuPtr{cuComplex}, lda::Cint,
                                 x::CuPtr{cuComplex}, incx::Cint, C::CuPtr{cuComplex},
                                 ldc::Cint)::cublasStatus_t
end

@checked function cublasCdgmm_64(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasCdgmm_64(handle::cublasHandle_t, mode::cublasSideMode_t,
                                    m::Int64, n::Int64, A::CuPtr{cuComplex}, lda::Int64,
                                    x::CuPtr{cuComplex}, incx::Int64, C::CuPtr{cuComplex},
                                    ldc::Int64)::cublasStatus_t
end

@checked function cublasZdgmm(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZdgmm(handle::cublasHandle_t, mode::cublasSideMode_t, m::Cint,
                                 n::Cint, A::CuPtr{cuDoubleComplex}, lda::Cint,
                                 x::CuPtr{cuDoubleComplex}, incx::Cint,
                                 C::CuPtr{cuDoubleComplex}, ldc::Cint)::cublasStatus_t
end

@checked function cublasZdgmm_64(handle, mode, m, n, A, lda, x, incx, C, ldc)
    initialize_context()
    @ccall libcublas.cublasZdgmm_64(handle::cublasHandle_t, mode::cublasSideMode_t,
                                    m::Int64, n::Int64, A::CuPtr{cuDoubleComplex},
                                    lda::Int64, x::CuPtr{cuDoubleComplex}, incx::Int64,
                                    C::CuPtr{cuDoubleComplex}, ldc::Int64)::cublasStatus_t
end

@checked function cublasSmatinvBatched(handle, n, A, lda, Ainv, lda_inv, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasSmatinvBatched(handle::cublasHandle_t, n::Cint,
                                          A::CuPtr{Ptr{Cfloat}}, lda::Cint,
                                          Ainv::CuPtr{Ptr{Cfloat}}, lda_inv::Cint,
                                          info::CuPtr{Cint},
                                          batchSize::Cint)::cublasStatus_t
end

@checked function cublasDmatinvBatched(handle, n, A, lda, Ainv, lda_inv, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasDmatinvBatched(handle::cublasHandle_t, n::Cint,
                                          A::CuPtr{Ptr{Cdouble}}, lda::Cint,
                                          Ainv::CuPtr{Ptr{Cdouble}}, lda_inv::Cint,
                                          info::CuPtr{Cint},
                                          batchSize::Cint)::cublasStatus_t
end

@checked function cublasCmatinvBatched(handle, n, A, lda, Ainv, lda_inv, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasCmatinvBatched(handle::cublasHandle_t, n::Cint,
                                          A::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                          Ainv::CuPtr{Ptr{cuComplex}}, lda_inv::Cint,
                                          info::CuPtr{Cint},
                                          batchSize::Cint)::cublasStatus_t
end

@checked function cublasZmatinvBatched(handle, n, A, lda, Ainv, lda_inv, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasZmatinvBatched(handle::cublasHandle_t, n::Cint,
                                          A::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                          Ainv::CuPtr{Ptr{cuDoubleComplex}}, lda_inv::Cint,
                                          info::CuPtr{Cint},
                                          batchSize::Cint)::cublasStatus_t
end

@checked function cublasSgeqrfBatched(handle, m, n, Aarray, lda, TauArray, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasSgeqrfBatched(handle::cublasHandle_t, m::Cint, n::Cint,
                                         Aarray::CuPtr{Ptr{Cfloat}}, lda::Cint,
                                         TauArray::CuPtr{Ptr{Cfloat}}, info::Ptr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasDgeqrfBatched(handle, m, n, Aarray, lda, TauArray, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasDgeqrfBatched(handle::cublasHandle_t, m::Cint, n::Cint,
                                         Aarray::CuPtr{Ptr{Cdouble}}, lda::Cint,
                                         TauArray::CuPtr{Ptr{Cdouble}}, info::Ptr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasCgeqrfBatched(handle, m, n, Aarray, lda, TauArray, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasCgeqrfBatched(handle::cublasHandle_t, m::Cint, n::Cint,
                                         Aarray::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                         TauArray::CuPtr{Ptr{cuComplex}}, info::Ptr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasZgeqrfBatched(handle, m, n, Aarray, lda, TauArray, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasZgeqrfBatched(handle::cublasHandle_t, m::Cint, n::Cint,
                                         Aarray::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                         TauArray::CuPtr{Ptr{cuDoubleComplex}},
                                         info::Ptr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasSgelsBatched(handle, trans, m, n, nrhs, Aarray, lda, Carray, ldc,
                                     info, devInfoArray, batchSize)
    initialize_context()
    @ccall libcublas.cublasSgelsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, nrhs::Cint,
                                        Aarray::CuPtr{Ptr{Cfloat}}, lda::Cint,
                                        Carray::CuPtr{Ptr{Cfloat}}, ldc::Cint,
                                        info::Ptr{Cint}, devInfoArray::CuPtr{Cint},
                                        batchSize::Cint)::cublasStatus_t
end

@checked function cublasDgelsBatched(handle, trans, m, n, nrhs, Aarray, lda, Carray, ldc,
                                     info, devInfoArray, batchSize)
    initialize_context()
    @ccall libcublas.cublasDgelsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, nrhs::Cint,
                                        Aarray::CuPtr{Ptr{Cdouble}}, lda::Cint,
                                        Carray::CuPtr{Ptr{Cdouble}}, ldc::Cint,
                                        info::Ptr{Cint}, devInfoArray::CuPtr{Cint},
                                        batchSize::Cint)::cublasStatus_t
end

@checked function cublasCgelsBatched(handle, trans, m, n, nrhs, Aarray, lda, Carray, ldc,
                                     info, devInfoArray, batchSize)
    initialize_context()
    @ccall libcublas.cublasCgelsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, nrhs::Cint,
                                        Aarray::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                        Carray::CuPtr{Ptr{cuComplex}}, ldc::Cint,
                                        info::Ptr{Cint}, devInfoArray::CuPtr{Cint},
                                        batchSize::Cint)::cublasStatus_t
end

@checked function cublasZgelsBatched(handle, trans, m, n, nrhs, Aarray, lda, Carray, ldc,
                                     info, devInfoArray, batchSize)
    initialize_context()
    @ccall libcublas.cublasZgelsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                        m::Cint, n::Cint, nrhs::Cint,
                                        Aarray::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                        Carray::CuPtr{Ptr{cuDoubleComplex}}, ldc::Cint,
                                        info::Ptr{Cint}, devInfoArray::CuPtr{Cint},
                                        batchSize::Cint)::cublasStatus_t
end

@checked function cublasStpttr(handle, uplo, n, AP, A, lda)
    initialize_context()
    @ccall libcublas.cublasStpttr(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  AP::CuPtr{Cfloat}, A::CuPtr{Cfloat},
                                  lda::Cint)::cublasStatus_t
end

@checked function cublasDtpttr(handle, uplo, n, AP, A, lda)
    initialize_context()
    @ccall libcublas.cublasDtpttr(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  AP::CuPtr{Cdouble}, A::CuPtr{Cdouble},
                                  lda::Cint)::cublasStatus_t
end

@checked function cublasCtpttr(handle, uplo, n, AP, A, lda)
    initialize_context()
    @ccall libcublas.cublasCtpttr(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  AP::CuPtr{cuComplex}, A::CuPtr{cuComplex},
                                  lda::Cint)::cublasStatus_t
end

@checked function cublasZtpttr(handle, uplo, n, AP, A, lda)
    initialize_context()
    @ccall libcublas.cublasZtpttr(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  AP::CuPtr{cuDoubleComplex}, A::CuPtr{cuDoubleComplex},
                                  lda::Cint)::cublasStatus_t
end

@checked function cublasStrttp(handle, uplo, n, A, lda, AP)
    initialize_context()
    @ccall libcublas.cublasStrttp(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  A::CuPtr{Cfloat}, lda::Cint,
                                  AP::CuPtr{Cfloat})::cublasStatus_t
end

@checked function cublasDtrttp(handle, uplo, n, A, lda, AP)
    initialize_context()
    @ccall libcublas.cublasDtrttp(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  A::CuPtr{Cdouble}, lda::Cint,
                                  AP::CuPtr{Cdouble})::cublasStatus_t
end

@checked function cublasCtrttp(handle, uplo, n, A, lda, AP)
    initialize_context()
    @ccall libcublas.cublasCtrttp(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  A::CuPtr{cuComplex}, lda::Cint,
                                  AP::CuPtr{cuComplex})::cublasStatus_t
end

@checked function cublasZtrttp(handle, uplo, n, A, lda, AP)
    initialize_context()
    @ccall libcublas.cublasZtrttp(handle::cublasHandle_t, uplo::cublasFillMode_t, n::Cint,
                                  A::CuPtr{cuDoubleComplex}, lda::Cint,
                                  AP::CuPtr{cuDoubleComplex})::cublasStatus_t
end

@checked function cublasSgetrfBatched(handle, n, A, lda, P, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasSgetrfBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{Cfloat}}, lda::Cint, P::CuPtr{Cint},
                                         info::CuPtr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasDgetrfBatched(handle, n, A, lda, P, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasDgetrfBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{Cdouble}}, lda::Cint, P::CuPtr{Cint},
                                         info::CuPtr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasCgetrfBatched(handle, n, A, lda, P, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasCgetrfBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                         P::CuPtr{Cint}, info::CuPtr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasZgetrfBatched(handle, n, A, lda, P, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasZgetrfBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                         P::CuPtr{Cint}, info::CuPtr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasSgetriBatched(handle, n, A, lda, P, C, ldc, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasSgetriBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{Cfloat}}, lda::Cint, P::CuPtr{Cint},
                                         C::CuPtr{Ptr{Cfloat}}, ldc::Cint,
                                         info::CuPtr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasDgetriBatched(handle, n, A, lda, P, C, ldc, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasDgetriBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{Cdouble}}, lda::Cint, P::CuPtr{Cint},
                                         C::CuPtr{Ptr{Cdouble}}, ldc::Cint,
                                         info::CuPtr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasCgetriBatched(handle, n, A, lda, P, C, ldc, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasCgetriBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{cuComplex}}, lda::Cint,
                                         P::CuPtr{Cint}, C::CuPtr{Ptr{cuComplex}},
                                         ldc::Cint, info::CuPtr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasZgetriBatched(handle, n, A, lda, P, C, ldc, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasZgetriBatched(handle::cublasHandle_t, n::Cint,
                                         A::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                         P::CuPtr{Cint}, C::CuPtr{Ptr{cuDoubleComplex}},
                                         ldc::Cint, info::CuPtr{Cint},
                                         batchSize::Cint)::cublasStatus_t
end

@checked function cublasSgetrsBatched(handle, trans, n, nrhs, Aarray, lda, devIpiv, Barray,
                                      ldb, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasSgetrsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                         n::Cint, nrhs::Cint, Aarray::CuPtr{Ptr{Cfloat}},
                                         lda::Cint, devIpiv::CuPtr{Cint},
                                         Barray::CuPtr{Ptr{Cfloat}}, ldb::Cint,
                                         info::Ptr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasDgetrsBatched(handle, trans, n, nrhs, Aarray, lda, devIpiv, Barray,
                                      ldb, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasDgetrsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                         n::Cint, nrhs::Cint, Aarray::CuPtr{Ptr{Cdouble}},
                                         lda::Cint, devIpiv::CuPtr{Cint},
                                         Barray::CuPtr{Ptr{Cdouble}}, ldb::Cint,
                                         info::Ptr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasCgetrsBatched(handle, trans, n, nrhs, Aarray, lda, devIpiv, Barray,
                                      ldb, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasCgetrsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                         n::Cint, nrhs::Cint, Aarray::CuPtr{Ptr{cuComplex}},
                                         lda::Cint, devIpiv::CuPtr{Cint},
                                         Barray::CuPtr{Ptr{cuComplex}}, ldb::Cint,
                                         info::Ptr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasZgetrsBatched(handle, trans, n, nrhs, Aarray, lda, devIpiv, Barray,
                                      ldb, info, batchSize)
    initialize_context()
    @ccall libcublas.cublasZgetrsBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                         n::Cint, nrhs::Cint,
                                         Aarray::CuPtr{Ptr{cuDoubleComplex}}, lda::Cint,
                                         devIpiv::CuPtr{Cint},
                                         Barray::CuPtr{Ptr{cuDoubleComplex}}, ldb::Cint,
                                         info::Ptr{Cint}, batchSize::Cint)::cublasStatus_t
end

@checked function cublasUint8gemmBias(handle, transa, transb, transc, m, n, k, A, A_bias,
                                      lda, B, B_bias, ldb, C, C_bias, ldc, C_mult, C_shift)
    initialize_context()
    @ccall libcublas.cublasUint8gemmBias(handle::cublasHandle_t, transa::cublasOperation_t,
                                         transb::cublasOperation_t,
                                         transc::cublasOperation_t, m::Cint, n::Cint,
                                         k::Cint, A::CuPtr{Cuchar}, A_bias::Cint, lda::Cint,
                                         B::CuPtr{Cuchar}, B_bias::Cint, ldb::Cint,
                                         C::CuPtr{Cuchar}, C_bias::Cint, ldc::Cint,
                                         C_mult::Cint, C_shift::Cint)::cublasStatus_t
end

mutable struct cublasXtContext end

const cublasXtHandle_t = Ptr{cublasXtContext}

@checked function cublasXtCreate(handle)
    initialize_context()
    @ccall libcublas.cublasXtCreate(handle::Ptr{cublasXtHandle_t})::cublasStatus_t
end

@checked function cublasXtDestroy(handle)
    initialize_context()
    @ccall libcublas.cublasXtDestroy(handle::cublasXtHandle_t)::cublasStatus_t
end

@checked function cublasXtGetNumBoards(nbDevices, deviceId, nbBoards)
    initialize_context()
    @ccall libcublas.cublasXtGetNumBoards(nbDevices::Cint, deviceId::Ptr{Cint},
                                          nbBoards::Ptr{Cint})::cublasStatus_t
end

@checked function cublasXtMaxBoards(nbGpuBoards)
    initialize_context()
    @ccall libcublas.cublasXtMaxBoards(nbGpuBoards::Ptr{Cint})::cublasStatus_t
end

@checked function cublasXtDeviceSelect(handle, nbDevices, deviceId)
    initialize_context()
    @ccall libcublas.cublasXtDeviceSelect(handle::cublasXtHandle_t, nbDevices::Cint,
                                          deviceId::Ptr{Cint})::cublasStatus_t
end

@checked function cublasXtSetBlockDim(handle, blockDim)
    initialize_context()
    @ccall libcublas.cublasXtSetBlockDim(handle::cublasXtHandle_t,
                                         blockDim::Cint)::cublasStatus_t
end

@checked function cublasXtGetBlockDim(handle, blockDim)
    initialize_context()
    @ccall libcublas.cublasXtGetBlockDim(handle::cublasXtHandle_t,
                                         blockDim::Ptr{Cint})::cublasStatus_t
end

@cenum cublasXtPinnedMemMode_t::UInt32 begin
    CUBLASXT_PINNING_DISABLED = 0
    CUBLASXT_PINNING_ENABLED = 1
end

@checked function cublasXtGetPinningMemMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasXtGetPinningMemMode(handle::cublasXtHandle_t,
                                               mode::Ptr{cublasXtPinnedMemMode_t})::cublasStatus_t
end

@checked function cublasXtSetPinningMemMode(handle, mode)
    initialize_context()
    @ccall libcublas.cublasXtSetPinningMemMode(handle::cublasXtHandle_t,
                                               mode::cublasXtPinnedMemMode_t)::cublasStatus_t
end

@cenum cublasXtOpType_t::UInt32 begin
    CUBLASXT_FLOAT = 0
    CUBLASXT_DOUBLE = 1
    CUBLASXT_COMPLEX = 2
    CUBLASXT_DOUBLECOMPLEX = 3
end

@cenum cublasXtBlasOp_t::UInt32 begin
    CUBLASXT_GEMM = 0
    CUBLASXT_SYRK = 1
    CUBLASXT_HERK = 2
    CUBLASXT_SYMM = 3
    CUBLASXT_HEMM = 4
    CUBLASXT_TRSM = 5
    CUBLASXT_SYR2K = 6
    CUBLASXT_HER2K = 7
    CUBLASXT_SPMM = 8
    CUBLASXT_SYRKX = 9
    CUBLASXT_HERKX = 10
    CUBLASXT_TRMM = 11
    CUBLASXT_ROUTINE_MAX = 12
end

@checked function cublasXtSetCpuRoutine(handle, blasOp, type, blasFunctor)
    initialize_context()
    @ccall libcublas.cublasXtSetCpuRoutine(handle::cublasXtHandle_t,
                                           blasOp::cublasXtBlasOp_t, type::cublasXtOpType_t,
                                           blasFunctor::Ptr{Cvoid})::cublasStatus_t
end

@checked function cublasXtSetCpuRatio(handle, blasOp, type, ratio)
    initialize_context()
    @ccall libcublas.cublasXtSetCpuRatio(handle::cublasXtHandle_t, blasOp::cublasXtBlasOp_t,
                                         type::cublasXtOpType_t,
                                         ratio::Cfloat)::cublasStatus_t
end

@checked function cublasXtSgemm(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtSgemm(handle::cublasXtHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Csize_t, n::Csize_t,
                                   k::Csize_t, alpha::RefOrCuRef{Cfloat},
                                   A::PtrOrCuPtr{Cfloat}, lda::Csize_t,
                                   B::PtrOrCuPtr{Cfloat}, ldb::Csize_t,
                                   beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{Cfloat},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDgemm(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtDgemm(handle::cublasXtHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Csize_t, n::Csize_t,
                                   k::Csize_t, alpha::RefOrCuRef{Cdouble},
                                   A::PtrOrCuPtr{Cdouble}, lda::Csize_t,
                                   B::PtrOrCuPtr{Cdouble}, ldb::Csize_t,
                                   beta::RefOrCuRef{Cdouble}, C::PtrOrCuPtr{Cdouble},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCgemm(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtCgemm(handle::cublasXtHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Csize_t, n::Csize_t,
                                   k::Csize_t, alpha::RefOrCuRef{cuComplex},
                                   A::PtrOrCuPtr{cuComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZgemm(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb,
                                beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtZgemm(handle::cublasXtHandle_t, transa::cublasOperation_t,
                                   transb::cublasOperation_t, m::Csize_t, n::Csize_t,
                                   k::Csize_t, alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuDoubleComplex},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtSsyrk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtSsyrk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                   lda::Csize_t, beta::RefOrCuRef{Cfloat},
                                   C::PtrOrCuPtr{Cfloat}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDsyrk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtDsyrk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                   lda::Csize_t, beta::RefOrCuRef{Cdouble},
                                   C::PtrOrCuPtr{Cdouble}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCsyrk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtCsyrk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, beta::RefOrCuRef{cuComplex},
                                   C::PtrOrCuPtr{cuComplex}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZsyrk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtZsyrk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   beta::RefOrCuRef{cuDoubleComplex},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCherk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtCherk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, beta::RefOrCuRef{Cfloat},
                                   C::PtrOrCuPtr{cuComplex}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZherk(handle, uplo, trans, n, k, alpha, A, lda, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtZherk(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                   trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                   alpha::RefOrCuRef{Cdouble},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   beta::RefOrCuRef{Cdouble},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtSsyr2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtSsyr2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                    lda::Csize_t, B::PtrOrCuPtr{Cfloat}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{Cfloat},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDsyr2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtDsyr2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                    lda::Csize_t, B::PtrOrCuPtr{Cdouble}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cdouble}, C::PtrOrCuPtr{Cdouble},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCsyr2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtCsyr2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                    lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZsyr2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtZsyr2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                    B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::PtrOrCuPtr{cuDoubleComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCherkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtCherkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                    lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{cuComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZherkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtZherkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                    B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cdouble},
                                    C::PtrOrCuPtr{cuDoubleComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtStrsm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb)
    initialize_context()
    @ccall libcublas.cublasXtStrsm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                   lda::Csize_t, B::PtrOrCuPtr{Cfloat},
                                   ldb::Csize_t)::cublasStatus_t
end

@checked function cublasXtDtrsm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb)
    initialize_context()
    @ccall libcublas.cublasXtDtrsm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                   lda::Csize_t, B::PtrOrCuPtr{Cdouble},
                                   ldb::Csize_t)::cublasStatus_t
end

@checked function cublasXtCtrsm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb)
    initialize_context()
    @ccall libcublas.cublasXtCtrsm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, B::PtrOrCuPtr{cuComplex},
                                   ldb::Csize_t)::cublasStatus_t
end

@checked function cublasXtZtrsm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb)
    initialize_context()
    @ccall libcublas.cublasXtZtrsm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuDoubleComplex},
                                   ldb::Csize_t)::cublasStatus_t
end

@checked function cublasXtSsymm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtSsymm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                   lda::Csize_t, B::PtrOrCuPtr{Cfloat}, ldb::Csize_t,
                                   beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{Cfloat},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDsymm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtDsymm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                   lda::Csize_t, B::PtrOrCuPtr{Cdouble}, ldb::Csize_t,
                                   beta::RefOrCuRef{Cdouble}, C::PtrOrCuPtr{Cdouble},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCsymm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtCsymm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZsymm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtZsymm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuDoubleComplex},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtChemm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtChemm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZhemm(handle, side, uplo, m, n, alpha, A, lda, B, ldb, beta, C,
                                ldc)
    initialize_context()
    @ccall libcublas.cublasXtZhemm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                   beta::RefOrCuRef{cuDoubleComplex},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtSsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtSsyrkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                    lda::Csize_t, B::PtrOrCuPtr{Cfloat}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{Cfloat},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtDsyrkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                    lda::Csize_t, B::PtrOrCuPtr{Cdouble}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cdouble}, C::PtrOrCuPtr{Cdouble},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtCsyrkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                    lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZsyrkx(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtZsyrkx(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                    B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{cuDoubleComplex},
                                    C::PtrOrCuPtr{cuDoubleComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCher2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtCher2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                    lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cfloat}, C::PtrOrCuPtr{cuComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZher2k(handle, uplo, trans, n, k, alpha, A, lda, B, ldb, beta, C,
                                 ldc)
    initialize_context()
    @ccall libcublas.cublasXtZher2k(handle::cublasXtHandle_t, uplo::cublasFillMode_t,
                                    trans::cublasOperation_t, n::Csize_t, k::Csize_t,
                                    alpha::RefOrCuRef{cuDoubleComplex},
                                    A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                    B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                    beta::RefOrCuRef{Cdouble},
                                    C::PtrOrCuPtr{cuDoubleComplex},
                                    ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtSspmm(handle, side, uplo, m, n, alpha, AP, B, ldb, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtSspmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::Ref{Cfloat}, AP::Ptr{Cfloat},
                                   B::PtrOrCuPtr{Cfloat}, ldb::Csize_t, beta::Ref{Cfloat},
                                   C::PtrOrCuPtr{Cfloat}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDspmm(handle, side, uplo, m, n, alpha, AP, B, ldb, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtDspmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::Ref{Cdouble}, AP::Ptr{Cdouble},
                                   B::PtrOrCuPtr{Cdouble}, ldb::Csize_t, beta::Ref{Cdouble},
                                   C::PtrOrCuPtr{Cdouble}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCspmm(handle, side, uplo, m, n, alpha, AP, B, ldb, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtCspmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::Ref{cuComplex}, AP::Ptr{cuComplex},
                                   B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                   beta::Ref{cuComplex}, C::PtrOrCuPtr{cuComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZspmm(handle, side, uplo, m, n, alpha, AP, B, ldb, beta, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtZspmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, m::Csize_t, n::Csize_t,
                                   alpha::Ref{cuDoubleComplex}, AP::Ptr{cuDoubleComplex},
                                   B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                   beta::Ref{cuDoubleComplex},
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtStrmm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtStrmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cfloat}, A::PtrOrCuPtr{Cfloat},
                                   lda::Csize_t, B::PtrOrCuPtr{Cfloat}, ldb::Csize_t,
                                   C::PtrOrCuPtr{Cfloat}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtDtrmm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtDtrmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{Cdouble}, A::PtrOrCuPtr{Cdouble},
                                   lda::Csize_t, B::PtrOrCuPtr{Cdouble}, ldb::Csize_t,
                                   C::PtrOrCuPtr{Cdouble}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtCtrmm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtCtrmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuComplex}, A::PtrOrCuPtr{cuComplex},
                                   lda::Csize_t, B::PtrOrCuPtr{cuComplex}, ldb::Csize_t,
                                   C::PtrOrCuPtr{cuComplex}, ldc::Csize_t)::cublasStatus_t
end

@checked function cublasXtZtrmm(handle, side, uplo, trans, diag, m, n, alpha, A, lda, B,
                                ldb, C, ldc)
    initialize_context()
    @ccall libcublas.cublasXtZtrmm(handle::cublasXtHandle_t, side::cublasSideMode_t,
                                   uplo::cublasFillMode_t, trans::cublasOperation_t,
                                   diag::cublasDiagType_t, m::Csize_t, n::Csize_t,
                                   alpha::RefOrCuRef{cuDoubleComplex},
                                   A::PtrOrCuPtr{cuDoubleComplex}, lda::Csize_t,
                                   B::PtrOrCuPtr{cuDoubleComplex}, ldb::Csize_t,
                                   C::PtrOrCuPtr{cuDoubleComplex},
                                   ldc::Csize_t)::cublasStatus_t
end

# Float16 functionality is only enabled when using C++ (defining __cplusplus breaks things)

@checked function cublasHSHgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                       incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasHSHgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                          m::Cint, n::Cint, alpha::Ptr{Cfloat},
                                          Aarray::Ptr{Ptr{Float16}}, lda::Cint,
                                          xarray::Ptr{Ptr{Float16}}, incx::Cint,
                                          beta::Ptr{Cfloat}, yarray::Ptr{Ptr{Float16}},
                                          incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasHSSgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                       incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasHSSgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                          m::Cint, n::Cint, alpha::Ptr{Cfloat},
                                          Aarray::Ptr{Ptr{Float16}}, lda::Cint,
                                          xarray::Ptr{Ptr{Float16}}, incx::Cint,
                                          beta::Ptr{Cfloat}, yarray::Ptr{Ptr{Cfloat}},
                                          incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasTSTgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                       incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasTSTgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                          m::Cint, n::Cint, alpha::Ptr{Cfloat},
                                          Aarray::Ptr{Ptr{BFloat16}}, lda::Cint,
                                          xarray::Ptr{Ptr{BFloat16}}, incx::Cint,
                                          beta::Ptr{Cfloat}, yarray::Ptr{Ptr{BFloat16}},
                                          incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasTSSgemvBatched(handle, trans, m, n, alpha, Aarray, lda, xarray,
                                       incx, beta, yarray, incy, batchCount)
    initialize_context()
    @ccall libcublas.cublasTSSgemvBatched(handle::cublasHandle_t, trans::cublasOperation_t,
                                          m::Cint, n::Cint, alpha::Ptr{Cfloat},
                                          Aarray::Ptr{Ptr{BFloat16}}, lda::Cint,
                                          xarray::Ptr{Ptr{BFloat16}}, incx::Cint,
                                          beta::Ptr{Cfloat}, yarray::Ptr{Ptr{Cfloat}},
                                          incy::Cint, batchCount::Cint)::cublasStatus_t
end

@checked function cublasHSHgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA,
                                              x, incx, stridex, beta, y, incy, stridey,
                                              batchCount)
    initialize_context()
    @ccall libcublas.cublasHSHgemvStridedBatched(handle::cublasHandle_t,
                                                 trans::cublasOperation_t, m::Cint, n::Cint,
                                                 alpha::Ptr{Cfloat}, A::Ptr{Float16},
                                                 lda::Cint, strideA::Clonglong,
                                                 x::Ptr{Float16}, incx::Cint,
                                                 stridex::Clonglong, beta::Ptr{Cfloat},
                                                 y::Ptr{Float16}, incy::Cint,
                                                 stridey::Clonglong,
                                                 batchCount::Cint)::cublasStatus_t
end

@checked function cublasHSSgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA,
                                              x, incx, stridex, beta, y, incy, stridey,
                                              batchCount)
    initialize_context()
    @ccall libcublas.cublasHSSgemvStridedBatched(handle::cublasHandle_t,
                                                 trans::cublasOperation_t, m::Cint, n::Cint,
                                                 alpha::Ptr{Cfloat}, A::Ptr{Float16},
                                                 lda::Cint, strideA::Clonglong,
                                                 x::Ptr{Float16}, incx::Cint,
                                                 stridex::Clonglong, beta::Ptr{Cfloat},
                                                 y::Ptr{Cfloat}, incy::Cint,
                                                 stridey::Clonglong,
                                                 batchCount::Cint)::cublasStatus_t
end

@checked function cublasTSTgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA,
                                              x, incx, stridex, beta, y, incy, stridey,
                                              batchCount)
    initialize_context()
    @ccall libcublas.cublasTSTgemvStridedBatched(handle::cublasHandle_t,
                                                 trans::cublasOperation_t, m::Cint, n::Cint,
                                                 alpha::Ptr{Cfloat}, A::Ptr{BFloat16},
                                                 lda::Cint, strideA::Clonglong,
                                                 x::Ptr{BFloat16}, incx::Cint,
                                                 stridex::Clonglong, beta::Ptr{Cfloat},
                                                 y::Ptr{BFloat16}, incy::Cint,
                                                 stridey::Clonglong,
                                                 batchCount::Cint)::cublasStatus_t
end

@checked function cublasTSSgemvStridedBatched(handle, trans, m, n, alpha, A, lda, strideA,
                                              x, incx, stridex, beta, y, incy, stridey,
                                              batchCount)
    initialize_context()
    @ccall libcublas.cublasTSSgemvStridedBatched(handle::cublasHandle_t,
                                                 trans::cublasOperation_t, m::Cint, n::Cint,
                                                 alpha::Ptr{Cfloat}, A::Ptr{BFloat16},
                                                 lda::Cint, strideA::Clonglong,
                                                 x::Ptr{BFloat16}, incx::Cint,
                                                 stridex::Clonglong, beta::Ptr{Cfloat},
                                                 y::Ptr{Cfloat}, incy::Cint,
                                                 stridey::Clonglong,
                                                 batchCount::Cint)::cublasStatus_t
end

@checked function cublasHgemm(handle, transa, transb, m, n, k, alpha, A, lda, B, ldb, beta,
                              C, ldc)
    initialize_context()
    @ccall libcublas.cublasHgemm(handle::cublasHandle_t, transa::cublasOperation_t,
                                 transb::cublasOperation_t, m::Cint, n::Cint, k::Cint,
                                 alpha::Ptr{Float16}, A::Ptr{Float16}, lda::Cint,
                                 B::Ptr{Float16}, ldb::Cint, beta::Ptr{Float16},
                                 C::Ptr{Float16}, ldc::Cint)::cublasStatus_t
end

@checked function cublasHgemmBatched(handle, transa, transb, m, n, k, alpha, Aarray, lda,
                                     Barray, ldb, beta, Carray, ldc, batchCount)
    initialize_context()
    @ccall libcublas.cublasHgemmBatched(handle::cublasHandle_t, transa::cublasOperation_t,
                                        transb::cublasOperation_t, m::Cint, n::Cint,
                                        k::Cint, alpha::RefOrCuRef{Float16},
                                        Aarray::CuPtr{Ptr{Float16}}, lda::Cint,
                                        Barray::CuPtr{Ptr{Float16}}, ldb::Cint,
                                        beta::RefOrCuRef{Float16},
                                        Carray::CuPtr{Ptr{Float16}}, ldc::Cint,
                                        batchCount::Cint)::cublasStatus_t
end

@checked function cublasHgemmStridedBatched(handle, transa, transb, m, n, k, alpha, A, lda,
                                            strideA, B, ldb, strideB, beta, C, ldc, strideC,
                                            batchCount)
    initialize_context()
    @ccall libcublas.cublasHgemmStridedBatched(handle::cublasHandle_t,
                                               transa::cublasOperation_t,
                                               transb::cublasOperation_t, m::Cint, n::Cint,
                                               k::Cint, alpha::RefOrCuRef{Float16},
                                               A::CuPtr{Float16}, lda::Cint,
                                               strideA::Clonglong, B::CuPtr{Float16},
                                               ldb::Cint, strideB::Clonglong,
                                               beta::RefOrCuRef{Float16}, C::CuPtr{Float16},
                                               ldc::Cint, strideC::Clonglong,
                                               batchCount::Cint)::cublasStatus_t
end
