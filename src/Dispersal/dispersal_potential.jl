
function (generator::IBDandCutoff)(;
                                   metapopulation::Metapopulation=PoissonProcess(), 
)  
    alpha = draw_from_parameter(generator.alpha)
    epsilon = draw_from_parameter(generator.epsilon)
    kernel = generator.kernel

    num_populations = get_number_populations(metapopulation)
    matrix::Array{Float64,2} = zeros(num_populations, num_populations)

    for i = 1:num_populations
        row_sum = 0.0
        for j = 1:num_populations
            if (i != j)
                kernel_val = kernel(alpha, get_distance_between_pops(metapopulation.populations[i], metapopulation.populations[j]))
                if (kernel_val > epsilon)
                    matrix[i,j] = kernel_val
                    row_sum += kernel_val
                end
            end
        end

        # Normalize
        if (row_sum > 0.0)
            for j = 1:num_populations
                matrix[i,j] = matrix[i,j] / row_sum
            end
        else
            # no edges for node i
            matrix[i,i] = 1.0
        end
    end

    return DispersalPotential(matrix)
end


function draw_from_dispersal_potential_row(dispersal_potential::DispersalPotential, row::Int64)
    return rand(Categorical(dispersal_potential.matrix[row,:]))
end
